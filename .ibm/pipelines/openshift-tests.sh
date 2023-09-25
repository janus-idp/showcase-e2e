#!/bin/sh

set -e

function cleanup {
    echo "Cleaning up before exiting"
    helm uninstall ${RELEASE_NAME} -n ${NAME_SPACE}
    rm -rf ~/tmpbin
}

# This will run the 'cleanup' function on exit, regardless of exit status:
trap cleanup EXIT

add_helm_repos() {
    # check installed helm version
    helm version

    # Check if the bitnami repository already exists
    if ! helm repo list | grep -q "^bitnami"; then
        helm repo add bitnami https://charts.bitnami.com/bitnami
    else
        echo "Repository bitnami already exists - updating repository instead."
    fi

    # Check if the backstage repository already exists
    if ! helm repo list | grep -q "^backstage"; then
        helm repo add backstage https://backstage.github.io/charts
    else
        echo "Repository backstage already exists - updating repository instead."
    fi
    
    # Check if the backstage repository already exists
    if ! helm repo list | grep -q "^janus-idp"; then
        helm repo add janus-idp https://janus-idp.github.io/helm-backstage
    else
        echo "Repository janus-idp already exists - updating repository instead."
    fi
    
    # Check if the repository already exists
    if ! helm repo list | grep -q "^${HELM_REPO_NAME}"; then
        helm repo add "${HELM_REPO_NAME}" "${HELM_REPO_URL}"
    else
        echo "Repository ${HELM_REPO_NAME} already exists - updating repository instead."
    fi

    helm repo update
}

# install the latest ibmcloud cli on Linux
install_ibmcloud() {
  if [[ -x "$(command -v ibmcloud)" ]]; then
    echo "ibmcloud is already installed."
  else
    curl -fsSL https://clis.cloud.ibm.com/install/linux | sh
    echo "the latest ibmcloud cli installed successfully."
  fi
}

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

install_helm() {
  if [[ -x "$(command -v helm)" ]]; then
    echo "Helm is already installed."
  else
    echo "Installing Helm 3 client"
    mkdir ~/tmpbin && cd ~/tmpbin

    HELM_INSTALL_DIR=$(pwd)
    curl -sL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash -f
    export PATH=${HELM_INSTALL_DIR}:$PATH
    echo "helm client installed successfully."
  fi
}

LOGFILE="pr-${GIT_PR_NUMBER}-openshift-tests-${BUILD_NUMBER}"
echo "Log file: ${LOGFILE}"
# source ./.ibm/pipelines/functions.sh

# install ibmcloud
install_ibmcloud

ibmcloud version
ibmcloud config --check-version=false
ibmcloud plugin install -f container-registry
ibmcloud plugin install -f kubernetes-service

# Using pipeline configuration - environment properties
ibmcloud login -r "${IBM_REGION}" -g "${IBM_RSC_GROUP}" --apikey "${SERVICE_ID_API_KEY}"
ibmcloud oc cluster config --cluster "${OPENSHIFT_CLUSTER_ID}"

install_oc

oc version --client
# oc login -u apikey -p "${SERVICE_ID_API_KEY}" --server="${IBM_OPENSHIFT_ENDPOINT}"
oc login --token=${K8S_CLUSTER_TOKEN} --server=${K8S_CLUSTER_URL}

oc project ${NAME_SPACE}
WORKING_DIR=$(pwd)

install_helm
cd $WORKING_DIR

add_helm_repos

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
helm upgrade -i ${RELEASE_NAME} -n ${NAME_SPACE} ${HELM_REPO_NAME}/${HELM_IMAGE_NAME} -f $DIR/value_files/${HELM_CHART_VALUE_FILE_NAME} --set global.clusterRouterBase=${K8S_CLUSTER_ROUTER_BASE}

echo "Waiting for backstage deployment..."
sleep 45

echo "Display pods for verification..."
oc get pods -n ${NAME_SPACE}

# Check if Backstage is up and running
BACKSTAGE_URL_RESPONSE=$(curl -Is "$CYPRESS_baseUrl" | head -n 1)
echo "$BACKSTAGE_URL_RESPONSE"

cd $WORKING_DIR/e2e-test
yarn install

Xvfb :99 &
export DISPLAY=:99

yarn run cypress:run 

pkill Xvfb
