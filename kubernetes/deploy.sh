#!/bin/bash

# set -x

CONFIG_FILE="DEV"
if [ -n "${1}" ]; then
    CONFIG_FILE="${1}"
fi

# import key value pairs
source ./${CONFIG_FILE}

kubectl create namespace ${namespace}

./gen_template.sh $CONFIG_FILE database-storage.yaml | kubectl -n $namespace apply -f -

./gen_template.sh $CONFIG_FILE configmap.yaml | kubectl -n $namespace apply -f -
./gen_template.sh $CONFIG_FILE secrets.yaml | kubectl -n $namespace apply -f -

cat database.yaml | kubectl -n $namespace apply -f -
./gen_template.sh $CONFIG_FILE slurmdbd.yaml | kubectl -n $namespace apply -f -
./gen_template.sh $CONFIG_FILE slurmctld.yaml | kubectl -n $namespace apply -f -
