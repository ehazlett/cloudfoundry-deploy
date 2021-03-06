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
# install
log " Installing CloudFoundry (revision: $VCAP_REVISION)..."
if [ -e $HOME/.vcap_dev_setup ] ; then rm $HOME/.vcap_dev_setup ; fi
wget https://raw.github.com/cloudfoundry/vcap/master/dev_setup/bin/vcap_dev_setup -q --no-check-certificate -O $HOME/.vcap_dev_setup
chmod +x $HOME/.vcap_dev_setup
$HOME/.vcap_dev_setup -a -c all.yml -D $1 -r $REPO_BASE -b $VCAP_REVISION

if [ "$?" != "0" ]; then
    err "Error during CloudFoundry installation"
    exit 1
fi
# copy management script
cp cf_control.sh /usr/local/bin/cf_control
chmod +x /usr/local/bin/cf_control

log " Arcus CloudFoundry installation complete."
echo "  Run set_role.sh to activate the instance role (controller, service, dea, etc.)."
echo "  You can control this instance by using cf_control <start|stop|restart|tail>"
echo ""
