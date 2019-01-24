#!/bin/sh

. ./00-environment.sh

for i in "$@"
do
case $i in
    -s=*|--subscription=*)
    AZ_SUBSCRIPTION_ID="${i#*=}"
    shift # past argument=value
    ;;
    -i=*|--aad-id=*)
    AZ_AAD_CLIENT_ID="${i#*=}"
    shift # past argument=value
    ;;
    -u=*|--rhms-user=*)
    RHSM_USERNAME="${i#*=}"
    shift # past argument=value
    ;;
    -p=*|--rhms-pool-id=*)
    RHSM_POOL_ID="${i#*=}"
    RHSM_BROKER_POOL_ID=${RHSM_POOL_ID}
    shift # past argument=value
    ;;
    -a=*|--admin-username=*)
    ADMIN_USERNAME="${i#*=}"
    shift # past argument=value
    ;;
    -i=*|--parameters-in=*)
    PARAMETERS_IN_FILE="${i#*=}"
    shift # past argument=value
    ;;
    -o=*|--parameters-out=*)
    PARAMETERS_OUT_FILE="${i#*=}"
    shift # past argument=value
    ;;
    *)
          # unknown option
    ;;
esac
done

# Read sensitive data from stdin
while true; do
    read -s -p "RHSM_PASSWORD: " RHSM_PASSWORD_1
    echo
    read -s -p "RHSM_PASSWORD (again): " RHSM_PASSWORD_2
    echo
    [ "${RHSM_PASSWORD_1}" = "${RHSM_PASSWORD_2}" ] && break
echo "Please try again"
done
RHSM_PASSWORD=${RHSM_PASSWORD_1}

while true; do
    read -s -p "OPENSHIFT_PASSWORD: " OPENSHIFT_PASSWORD_1
    echo
    read -s -p "OPENSHIFT_PASSWORD (again): " OPENSHIFT_PASSWORD_2
    echo
    [ "${OPENSHIFT_PASSWORD_1}" = "${OPENSHIFT_PASSWORD_2}" ] && break
echo "Please try again"
done
OPENSHIFT_PASSWORD=${OPENSHIFT_PASSWORD_1}

while true; do
    read -s -p "AZ_SP_PASS: " AZ_SP_PASS_1
    echo
    read -s -p "AZ_SP_PASS (again): " AZ_SP_PASS_2
    echo
    [ "${AZ_SP_PASS_1}" = "${AZ_SP_PASS_2}" ] && break
echo "Please try again"
done
AZ_SP_PASS=${AZ_SP_PASS_1}

# Uncomment to use a custom cert...
#az keyvault secret set --vault-name KeyVaultName -n mastercafile --file ~/certificates/masterca.pem

# Let's update the parameters file with the specified values
TEMPLATE_PARAMETERS=$(cat ${PARAMETERS_IN_FILE})
TEMPLATE_PARAMETERS=$(echo ${TEMPLATE_PARAMETERS} | jq ".parameters.adminUsername.value = \"${ADMIN_USERNAME}\"")
TEMPLATE_PARAMETERS=$(echo ${TEMPLATE_PARAMETERS} | jq ".parameters.openshiftPassword.value = \"${OPENSHIFT_PASSWORD}\"")
TEMPLATE_PARAMETERS=$(echo ${TEMPLATE_PARAMETERS} | jq ".parameters.openshiftClusterPrefix.value = \"${OPENSHIFT_CLUSTER_PREFIX}\"")

TEMPLATE_PARAMETERS=$(echo ${TEMPLATE_PARAMETERS} | jq ".parameters.rhsmUsernameOrOrgId.value = \"${RHSM_USERNAME}\"")
TEMPLATE_PARAMETERS=$(echo ${TEMPLATE_PARAMETERS} | jq ".parameters.rhsmPasswordOrActivationKey.value = \"${RHSM_PASSWORD}\"")
TEMPLATE_PARAMETERS=$(echo ${TEMPLATE_PARAMETERS} | jq ".parameters.rhsmPoolId.value = \"${RHSM_POOL_ID}\"")
TEMPLATE_PARAMETERS=$(echo ${TEMPLATE_PARAMETERS} | jq ".parameters.rhsmBrokerPoolId.value = \"${RHSM_BROKER_POOL_ID}\"")

TEMPLATE_PARAMETERS=$(echo ${TEMPLATE_PARAMETERS} | jq ".parameters.sshPublicKey.value = \"$(cat ${AZ_SSH_KEY_FILE}.pub)\"")

TEMPLATE_PARAMETERS=$(echo ${TEMPLATE_PARAMETERS} | jq ".parameters.keyVaultResourceGroup.value = \"${AZ_KEY_VAULT_RESOURCE_GROUP}\"")
TEMPLATE_PARAMETERS=$(echo ${TEMPLATE_PARAMETERS} | jq ".parameters.keyVaultName.value = \"${AZ_KEY_VAULT}\"")
TEMPLATE_PARAMETERS=$(echo ${TEMPLATE_PARAMETERS} | jq ".parameters.keyVaultSecret.value = \"${AZ_KEY_VAULT_SECRET}\"")

TEMPLATE_PARAMETERS=$(echo ${TEMPLATE_PARAMETERS} | jq ".parameters.aadClientId.value = \"${AZ_AAD_CLIENT_ID}\"")
TEMPLATE_PARAMETERS=$(echo ${TEMPLATE_PARAMETERS} | jq ".parameters.aadClientSecret.value = \"${AZ_SP_PASS}\"")

echo ${TEMPLATE_PARAMETERS} > ${PARAMETERS_OUT_FILE}