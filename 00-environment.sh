#!/bin/sh

export AZ_LOCATION="westeurope"
export AZ_TEMPLATE_FILE="azuredeploy.json"
export AZ_PARAMETERS_FILE="azuredeploy.parameters.json"

export AZ_SSH_KEY_FILE="./bf-ocp"

export AZ_KEY_VAULT_RESOURCE_GROUP="BTFKeyVaultGroup"
export AZ_KEY_VAULT="BTFKV"
export AZ_KEY_VAULT_SECRET="BTFKVSecret"

export AZ_OPENSHIFT_RESOURCE_GROUP="BTFOpenshiftGroup"
export AZ_OPENSHIFT_GROUP_DEPLOYMENT="BTFOpenshiftDeployment"

export ADMIN_USERNAME="ocpadmin"
export OPENSHIFT_CLUSTER_PREFIX="btlcluster"
