#!/bin/bash
#
# Arcus CloudFoundry installation
#  (c) arcus.io 2012

source common.sh

if [ ! -e $HOME/cloudfoundry/.deployments/vcap ]; then echo "You must install CloudFoundry first"; exit 1; fi
if [ "$1" = ""]; then
    echo "Usage: $0 <ROLE>"
    echo "  Where <ROLE> is either controller, service, or dea"
    echo ""
    exit 1
fi
# copy vcap components
log " Configuring for $1"
cp -f $PROJECT_DIR/vcap_configs/$1_vcap_components.json $HOME/cloudfoundry/.deployments/vcap/config/vcap_components.json
