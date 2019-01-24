#!/bin/sh

. ./00-environment.sh

for i in "$@"
do
case $i in
    -s=*|--subscription=*)
    AZ_SUBSCRIPTION_ID="${i#*=}"
    shift # past argument=value
    ;;
    -t=*|--template=*)
    AZ_TEMPLATE_FILE="${i#*=}"
    shift # past argument=value
    ;;
    -p=*|--parameters=*)
    AZ_PARAMETERS_FILE="${i#*=}"
    shift # past argument=value
    ;;
    *)
          # unknown option
    ;;
esac
done

az login

az account set --subscription ${AZ_SUBSCRIPTION_ID}

# Deploy custom template
az group create -n ${AZ_OPENSHIFT_RESOURCE_GROUP} -l ${AZ_LOCATION}
az group deployment create --name ${AZ_OPENSHIFT_GROUP_DEPLOYMENT} \
  --template-file ${AZ_TEMPLATE_FILE} --parameters @${AZ_PARAMETERS_FILE} \
  --resource-group ${AZ_OPENSHIFT_RESOURCE_GROUP} \
  --no-wait