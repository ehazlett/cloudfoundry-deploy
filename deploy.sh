#!/bin/bash
#
# Arcus CloudFoundry installation
#  (c) arcus.io 2012

BRANCH='arcus-stable'
PROJECT_DIR='`pwd`'

function log() {
    tput bold
    tput setaf 2
    echo
    echo $*
    echo '-------------------------'
    tput sgr0
}
# check for root
if [ "$(id -u)" != "0" ]; then
    echo "You must be root to install..."
    exit 1
fi

log " Arcus CloudFoundry Install"

# check for git
if [ ! -e `which git` ] ; then
    echo "You must have git installed.  On ubuntu or debian, you can apt-get install git-core"
    exit 1
fi
# check for args
if [ "$1" = "" ] || [ "$2" = "" ] ; then
    echo "Usage: $0 <DEPLOY_TYPE> <NATS_HOST> <DOMAIN>\n\nWhere DEPLOY_TYPE is controller, db, or dea\nand NATS_HOST is the NATS MB host and DOMAIN is the custom domain (leave blank for vcap.me)\n"
    exit 1
fi
# edit configs
if [ "$(grep NATS_HOST all.yml)" != "" ] ; then
    cp all.yml $1.yml
    sed -i "s/NATS_HOST/$2/g" $1.yml 2>&1 > /dev/null
fi
# check for vcap
if [ ! -e "$HOME/vcap" ] ; then
    log " Cloning Arcus VCAP..."
    git clone https://github.com/arcus-io/vcap ~/vcap
    cd ~/vcap ; git checkout $BRANCH
fi
# install
log " Installing CloudFoundry..."
$HOME/vcap/dev_setup/bin/vcap_dev_setup -a -c $1.yml -D $3 -r https://github.com/arcus-io/vcap -b $BRANCH

if [ "$?" != "0" ]; then
    echo "Error during CloudFoundry installation"
    exit 1
fi
# copy vcap components
log " Configuring for $1"
cp -f $PROJECT_DIR/vcap_configs/$1_vcap_components.json $HOME/cloudfoundry/.deployments/vcap/config/vcap_components.json
# copy management script
cp cf_control.sh /usr/local/bin/cf_control
chmod +x /usr/local/bin/cf_control

log " Arcus CloudFoundry installation complete.
    You can start your instance by using cf_control <start|stop|restart|tail>"
