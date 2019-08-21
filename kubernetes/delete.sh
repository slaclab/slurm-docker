#!/bin/bash

# set -x

CONFIG_FILE="DEV"
if [ -n "${1}" ]; then
    CONFIG_FILE="${1}"
fi

# import key value pairs
source ./${CONFIG_FILE}

kubectl delete namespace ${namespace} -R

kubectl delete pv $namespace--mysql-data

