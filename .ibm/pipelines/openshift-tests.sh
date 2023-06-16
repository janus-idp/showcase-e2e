#!/bin/bash
LOGFILE="pr-${GIT_PR_NUMBER}-openshift-tests-${BUILD_NUMBER}"
echo "Log file: ${LOGFILE}"
# source ./.ibm/pipelines/functions.sh

# install the latest ibmcloud cli on Linux
install_ibmcloud() {
  if [[ -x "$(command -v ibmcloud)" ]]; then
    echo "ibmcloud is already installed."
  else
    curl -fsSL https://clis.cloud.ibm.com/install/linux | sh
    echo "the latest ibmcloud cli installed successfully."
  fi
}

# Call the function to install oc
install_ibmcloud

ibmcloud version
ibmcloud config --check-version=false
ibmcloud plugin install -f container-registry
ibmcloud plugin install -f kubernetes-service

ibmcloud login -r "${IBM_REGION}" -g "${IBM_RSC_GROUP}" --apikey "${SERVICE_ID_API_KEY}"
ibmcloud oc cluster config --cluster "${OPENSHIFT_CLUSTER_ID}"

install_oc() {
  if [[ -x "$(command -v oc)" ]]; then
    echo "oc is already installed."
  else
    curl -LO https://mirror.openshift.com/pub/openshift-v4/clients/oc/latest/linux/oc.tar.gz
    tar -xf oc.tar.gz
    mv oc /usr/local/bin/
    rm oc.tar.gz
    echo "oc installed successfully."
  fi
}

# Call the function to install oc
install_oc

oc version --client
oc login -u apikey -p "${SERVICE_ID_API_KEY}" --server="${IBM_OPENSHIFT_ENDPOINT}"
oc config current-context
oc project backstage

install_helm() {
  if [[ -x "$(command -v helm)" ]]; then
    echo "Helm is already installed."
  else
    echo "Installing Helm 3 client"

    WORKING_DIR=$(pwd)
    mkdir ~/tmpbin && cd ~/tmpbin

    HELM_INSTALL_DIR=$(pwd)
    curl -sL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash -f
    export PATH=${HELM_INSTALL_DIR}:$PATH

    cd $WORKING_DIR
    echo "helm client installed successfully."
  fi
}

install_helm

# check installed helm version
helm version

helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add backstage https://backstage.github.io/charts
helm repo add janus-idp https://janus-idp.github.io/helm-backstage
helm repo update
helm upgrade -i backstage janus-idp/backstage -n backstage --wait

echo "Waiting for backstage deployment..."
sleep 45

oc get pods -n backstage
oc port-forward -n backstage svc/backstage 7007:http-backend &
# Store the PID of the background process
PID=$!

sleep 15

# Check if Backstage is up and running
BACKSTAGE_URL="http://localhost:7007"
BACKSTAGE_URL_RESPONSE=$(curl -Is "$BACKSTAGE_URL" | head -n 1)
echo "$BACKSTAGE_URL_RESPONSE"

cd $WORKING_DIR/e2e-test
yarn install

Xvfb :99 &
export DISPLAY=:99

# yarn cypress run --headless --browser chrome
yarn run cypress:run 

pkill Xvfb

cd $WORKING_DIR

# Send Ctrl+C to the process
kill -INT $PID

helm uninstall backstage -n backstage

rm -rf ~/tmpbin
