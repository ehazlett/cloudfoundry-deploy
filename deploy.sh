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

log " Arcus CloudFoundry Install"

# check for git
if [ ! -e `which git` ] ; then
    err "You must have git installed.  On ubuntu or debian, you can apt-get install git-core"
    exit 1
fi

# check for usage
if [ "$1" = "-h" ]; then
    echo "Usage: $0 <DOMAIN>
    Where DOMAIN is the custom domain 
    (leave blank for vcap.me)"
    exit 0
fi
# check for vcap
if [ ! -e "$HOME/vcap" ] ; then
    log " Cloning VCAP..."
    git clone https://github.com/cloudfoundry/vcap ~/vcap
fi
# install
log " Installing CloudFoundry..."
$HOME/vcap/dev_setup/bin/vcap_dev_setup -a -c all.yml -D $1

if [ "$?" != "0" ]; then
    err "Error during CloudFoundry installation"
    exit 1
fi
# copy management script
cp cf_control.sh /usr/local/bin/cf_control
chmod +x /usr/local/bin/cf_control

log " Arcus CloudFoundry installation complete."
echo "  Run set_role.sh to activate the instance role (controller, service, dea, etc.)."
echo "  You can start your instance by using cf_control <start|stop|restart|tail>"
echo ""
