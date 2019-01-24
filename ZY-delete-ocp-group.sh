#!/bin/sh

. ./00-environment.sh

az login

az account set --subscription ${AZ_SUBSCRIPTION_ID}

echo "Deleting group ${AZ_OPENSHIFT_RESOURCE_GROUP} at ${AZ_LOCATION}"
az group delete -n ${AZ_OPENSHIFT_RESOURCE_GROUP}