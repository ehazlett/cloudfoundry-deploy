#!/bin/bash
#
# Arcus CloudFoundry installation
#  (c) arcus.io 2012

REVISION='a023a091e'
PROJECT_DIR='`pwd`'

function log() {
    tput bold
    tput setaf 4
    echo
    echo $*
    echo '-------------------------'
    tput sgr0
}
function err() {
    tput bold
    tput setaf 1
    echo $*
    tput sgr0
}
# check for root
if [ "$(id -u)" != "0" ]; then
    err "You must be root to install..."
    exit 1
fi

log " Arcus CloudFoundry Install"

# check for git
if [ ! -e `which git` ] ; then
    err "You must have git installed.  On ubuntu or debian, you can apt-get install git-core"
    exit 1
fi
# check for args
if [ "$1" = "" ] || [ "$2" = "" ] ; then
    echo "Usage: $0 <DEPLOY_TYPE> <NATS_HOST> <DOMAIN>
    Where DEPLOY_TYPE is controller, db, or dea and NATS_HOST 
    is the NATS MB host and DOMAIN is the custom domain 
    (leave blank for vcap.me)"
    exit 1
fi
# check for vcap
if [ ! -e "$HOME/vcap" ] ; then
    log " Cloning Arcus VCAP..."
    git clone https://github.com/cloudfoundry/vcap ~/vcap
    cd ~/vcap ; git checkout $REVISION
fi
# install
log " Installing CloudFoundry..."
$HOME/vcap/dev_setup/bin/vcap_dev_setup -a -c all.yml -D $3 -b $REVISION

if [ "$?" != "0" ]; then
    err "Error during CloudFoundry installation"
    exit 1
fi
# copy vcap components
log " Configuring for $1"
cp -f $PROJECT_DIR/vcap_configs/$1_vcap_components.json $HOME/cloudfoundry/.deployments/vcap/config/vcap_components.json
# copy management script
cp cf_control.sh /usr/local/bin/cf_control
chmod +x /usr/local/bin/cf_control

log " Arcus CloudFoundry installation complete."
echo "  You can start your instance by using cf_control <start|stop|restart|tail>"
echo ""
