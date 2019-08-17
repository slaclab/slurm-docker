#!/bin/bash

set -x

CONFIG_FILE="DEV"
if [ -n "${1}" ]; then
    CONFIG_FILE="${1}"
fi

# import key value pairs
source ./${CONFIG_FILE}

kubectl delete -n ${namespace} configmap slurm-config
kubectl create -n ${namespace} configmap slurm-config \
        --from-file=../slurm.conf \
        --from-file=../gres.conf
