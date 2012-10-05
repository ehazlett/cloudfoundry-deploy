#!/bin/bash

NATS_HOST=$1
NATS_USER=$2
NATS_PASS=$3
NATS_PORT=$4

if [ "$1" = "" ] || [ "$2" = "" ] || [ "$3" = "" ] || [ "$4" = "" ]; then
        echo "Usage: $0 <NATS_HOST> <NATS_USER> <NATS_PASS> <NATS_PORT>"
        exit 1
fi

find ~/cloudfoundry/.deployments -name "*.yml" -exec sed "s/mbus.*/mbus: nats:\/\/$2:$3@$1:$4/g" {} \;
