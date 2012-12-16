#!/bin/bash
#
# Arcus CloudFoundry installation
#  (c) arcus.io 2012

source common.sh

# check for root
if [ "$(id -u)" != "0" ]; then
    err "You must be root to install..."
    exit 1
fi

if [ ! -e $HOME/cloudfoundry/.deployments/vcap ]; then echo "You must install CloudFoundry first"; exit 1; fi
if [ "$1" = "" ]; then
    echo "Usage: $0 <ROLE>"
    echo "  Where <ROLE> is either controller, service, or dea"
    echo ""
    exit 1
fi
# copy vcap components
log " Configuring for $1"

if [ "$1" != "controller" ]; then
    # disable controller services
    sudo update-rc.d -f nginx_cc remove
    sudo update-rc.d -f nginx_sds remove
    sudo update-rc.d -f nginx_router remove
    sudo update-rc.d -f nats_server remove
    sudo update-rc.d -f vcap_redis remove

    sudo service nginx_cc stop
    sudo service nginx_sds stop
    sudo service nginx_router stop
    sudo service nats_server stop
    sudo service vcap_redis stop
fi
cp -f $PROJECT_DIR/vcap_configs/$1_vcap_components.json $HOME/cloudfoundry/.deployments/vcap/config/vcap_components.json
