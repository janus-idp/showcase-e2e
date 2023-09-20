#!/bin/bash

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
    WORKING_DIR=$(pwd)
    mkdir ~/tmpbin && cd ~/tmpbin

    HELM_INSTALL_DIR=$(pwd)
    curl -sL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash -f
    export PATH=${HELM_INSTALL_DIR}:$PATH

    cd $WORKING_DIR
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

# create a name space e.g. rhdh-test
if ! oc get namespace ${NAME_SPACE} > /dev/null 2>&1; then
    oc create namespace ${NAME_SPACE}
else
    echo "Namespace ${NAME_SPACE} already exists!"
fi

oc project ${NAME_SPACE}

install_helm

add_helm_repos

helm upgrade -i backstage janus-idp/backstage -n backstage --wait

# # KNOWN ISSUE: https://issues.redhat.com/browse/OCPBUGSM-37095
# # Install with CLI then upgrade with CONSOLE is failed
# helm upgrade -i ${RELEASE_NAME} -n ${NAME_SPACE} ${HELM_REPO_NAME}/${HELM_IMAGE_NAME} -f $DIR/value_files/${HELM_CHART_VALUE_FILE_NAME}
helm upgrade -i ${RELEASE_NAME} -n ${NAME_SPACE} ${HELM_REPO_NAME}/${HELM_IMAGE_NAME}

echo "Waiting for backstage deployment..."
sleep 45

oc get pods -n backstage

# oc port-forward -n backstage svc/backstage 7007:http-backend &
# # Store the PID of the background process
# PID=$!

# sleep 15

# # Check if Backstage is up and running
# BACKSTAGE_URL="http://localhost:7007"
# BACKSTAGE_URL_RESPONSE=$(curl -Is "$BACKSTAGE_URL" | head -n 1)
# echo "$BACKSTAGE_URL_RESPONSE"

# cd $WORKING_DIR/e2e-test
# yarn install

# Xvfb :99 &
# export DISPLAY=:99

# # yarn cypress run --headless --browser chrome
# yarn run cypress:run 

# pkill Xvfb

# cd $WORKING_DIR

# # Send Ctrl+C to the process
# kill -INT $PID

# helm uninstall backstage -n backstage

# rm -rf ~/tmpbin
