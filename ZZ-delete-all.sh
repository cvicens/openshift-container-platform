#!/bin/sh

. ./00-environment.sh

az login

az account set --subscription ${AZ_SUBSCRIPTION_ID}

echo "Deleting secret ${AZ_KEY_VAULT_SECRET} at KV ${AZ_KEY_VAULT}"
az keyvault secret delete --vault-name ${AZ_KEY_VAULT} -n ${AZ_KEY_VAULT_SECRET}

echo "Deleting key vault ${AZ_KEY_VAULT} at RG ${AZ_KEY_VAULT_RESOURCE_GROUP} at ${AZ_LOCATION}"
az keyvault delete -n ${AZ_KEY_VAULT} 

echo "Deleting group ${AZ_KEY_VAULT_RESOURCE_GROUP} at ${AZ_LOCATION}"
az group delete -n ${AZ_KEY_VAULT_RESOURCE_GROUP}

echo "Deleting group ${AZ_OPENSHIFT_RESOURCE_GROUP} at ${AZ_LOCATION}"
az group delete -n ${AZ_OPENSHIFT_RESOURCE_GROUP}