#!/bin/sh

. ./00-environment.sh

for i in "$@"
do
case $i in
    -s=*|--subscription=*)
    AZ_SUBSCRIPTION_ID="${i#*=}"
    shift # past argument=value
    ;;
    -p=*|--principal=*)
    AZ_SP_NAME="${i#*=}"
    shift # past argument=value
    ;;
    *)
          # unknown option
    ;;
esac
done

while true; do
    read -s -p "AZ_SP_PASS: " AZ_SP_PASS_1
    echo
    read -s -p "AZ_SP_PASS (again): " AZ_SP_PASS_2
    echo
    [ "${AZ_SP_PASS_1}" = "${AZ_SP_PASS_2}" ] && break
echo "Please try again"
done
AZ_SP_PASS=${AZ_SP_PASS_1}

az login

az account set --subscription ${AZ_SUBSCRIPTION_ID}

ssh-keygen -t rsa -b 2048 -f ${AZ_SSH_KEY_FILE} -P ''

echo "Creating group ${AZ_KEY_VAULT_RESOURCE_GROUP} at ${AZ_LOCATION}"
az group create -n ${AZ_KEY_VAULT_RESOURCE_GROUP} -l ${AZ_LOCATION}

echo "Creating key vault ${AZ_KEY_VAULT} at RG ${AZ_KEY_VAULT_RESOURCE_GROUP} at ${AZ_LOCATION}"
az keyvault create -n ${AZ_KEY_VAULT} -g ${AZ_KEY_VAULT_RESOURCE_GROUP} -l ${AZ_LOCATION} --enabled-for-template-deployment true

echo "Creating secret ${AZ_KEY_VAULT_SECRET} at KV ${AZ_KEY_VAULT}"
az keyvault secret set --vault-name ${AZ_KEY_VAULT} -n ${AZ_KEY_VAULT_SECRET} --file ${AZ_SSH_KEY_FILE}

echo "Creating sp ${AZ_SP_NAME} /subscriptions/${AZ_SUBSCRIPTION_ID}/resourceGroups/${AZ_KEY_VAULT_RESOURCE_GROUP}"
#az ad sp create-for-rbac -n ${AZ_SP_NAME} --password ${AZ_SP_PASS} --role contributor --scopes /subscriptions/${AZ_SUBSCRIPTION_ID}
export AZ_SP_CREATE_RESULT=$(az ad sp create-for-rbac -n ${AZ_SP_NAME} --password ${AZ_SP_PASS} --role contributor --scopes /subscriptions/${AZ_SUBSCRIPTION_ID}/resourceGroups/${AZ_KEY_VAULT_RESOURCE_GROUP})
#az ad sp create-for-rbac -n ${AZ_SP_NAME} --password ${AZ_SP_PASS} --role contributor --skip-assignment

export AZ_AAD_CLIENT_ID=$(echo ${AZ_SP_CREATE_RESULT} | jq -r .appId)
echo "AZ_AAD_CLIENT_ID: ${AZ_AAD_CLIENT_ID}"
echo "AZ_SP_PASS: ${AZ_SP_PASS}"

# Uncomment to use a custom cert...
#az keyvault secret set --vault-name KeyVaultName -n mastercafile --file ~/certificates/masterca.pem