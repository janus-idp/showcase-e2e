# Save the logs from the file passed as parameter #1
# and send a message to GitHub PR using parameter #2 as name of test
# Env vars:
#  IBM_RESOURCE_GROUP: Resource group of the Cloud ObjectStorage
#  IBM_COS: Cloud Object Storage containing the bucket on which to save logs
#  IBM_BUCKET: Bucket name on which to save logs
save_logs() {
    OUTPUT_FILE_NAME="$1"
    NAME="$2"
    RESULT="$3"

    ansi2html <"/tmp/${OUTPUT_FILE_NAME}" >"/tmp/${OUTPUT_FILE_NAME}.html"
    
    # disabled redundant login and target
    # ibmcloud login --apikey "${API_KEY}"
    # ibmcloud target -g "${IBM_RESOURCE_GROUP}"  -r "${IBM_REGION}"
    CRN=$(ibmcloud resource service-instance ${IBM_COS} --output json | jq -r .[0].guid)
    ibmcloud cos config crn --crn "${CRN}"
    ibmcloud cos upload --bucket "${IBM_BUCKET}" --key "${OUTPUT_FILE_NAME}.html" --file "/tmp/${OUTPUT_FILE_NAME}.html" --content-type "text/html; charset=UTF-8"
    
    BASE_URL="https://s3.${IBM_REGION}.cloud-object-storage.appdomain.cloud/${IBM_BUCKET}"
    if [[ $RESULT == "0" ]]; then
        STATUS="successfully"
    else
        STATUS="with errors"
    fi

    cat <<EOF | pr-commenter -key-from-env-var ROBOT_KEY -application-id=${GITHUB_APP_PR_COMMENTER_ID} -pr-comment=${GIT_PR_NUMBER} -repository=${GITHUB_REPOSITORY_NAME} -org=${GITHUB_ORG_NAME}
${NAME} on commit ${GIT_COMMIT} finished **${STATUS}**.
View [test log](${BASE_URL}/${OUTPUT_FILE_NAME}.html)
EOF
}

save_junit() {
    OUTPUT_FILE_NAME="$1"
    NAME="$2"
    RESULT="$3"

    RESULTS_LOCATION="./cypress/results"
    JUNIT_ZIP_FILE="${OUTPUT_FILE_NAME}.zip"
    JUNIT_ZIP_FILE_LOCATION="/tmp/${ZIP_FILE}"

    zip -r $JUNIT_ZIP_FILE $RESULTS_LOCATION

    # disabled redundant login and target
    # ibmcloud login --apikey "${API_KEY}"
    # ibmcloud target -g "${IBM_RESOURCE_GROUP}"  -r "${IBM_REGION}"
    CRN=$(ibmcloud resource service-instance ${IBM_COS} --output json | jq -r .[0].guid)
    ibmcloud cos config crn --crn "${CRN}"
    ibmcloud cos upload --bucket "${IBM_BUCKET}" --key "${JUNIT_ZIP_FILE}" --file "${JUNIT_ZIP_FILE_LOCATION}" --content-type "text/xml; charset=UTF-8"

    curl -X POST "${SMEE_URL}" -H "Content-Type: application/json" -d '{"junit-archive": "'"${JUNIT_ZIP_FILE}"'"}'
}

skip_if_only() {
    echo "Checking if tests need to be executed..."

    if [ "$IBM_MANUAL_JOB" == "true" ]; then
        echo "This job was manually started. Continue the tests."
        return
    fi

    NAMES=$(git diff --merge-base --name-only main)
    for change in ${NAMES}; do
        skip $change
        if [[ $? == 0 ]]; then
            return
        fi
    done
    echo   "  => Skipping the tests."
    exit 0
}

skip() {
    SKIP_IF_ONLY="docs/ CONTRIBUTING.md OWNERS README.md USAGE_DATA.md scripts/ .github/ .threatmodel/ ui/"
    change=$1
    for skip in ${SKIP_IF_ONLY}; do
        if [[ "${change}" == "${skip}"* ]]; then
            echo "  - ${change} is ${skip}*"
            return 1
        fi
    done
    echo "  - $change not in $SKIP_IF_ONLY"
    return 0
}
