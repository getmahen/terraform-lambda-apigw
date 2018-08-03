#!/usr/bin/env bash
if [ $# = 0 ] ; then
    echo "!! must specify the environment (dev/qa/prod)"
    echo "   ./setEnv.sh dev"
    return
fi

ENV_FILE="./backendConfigs/$1"
if [ ! -f ${ENV_FILE} ] ; then
	echo "File $ENV_FILE not found"
	return
fi

rm -rf ./.terraform/
terraform init -backend-config=${ENV_FILE}

# attempt to set TF_VAR_environment to the appropriate env.   Will only work if script is sourced
export TF_VAR_environment=$1
