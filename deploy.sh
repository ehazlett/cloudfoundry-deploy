#!/bin/sh

if [ "$UID" != "0" ]; then
    echo "You must be root to install..."
    exit 1
fi

echo "---------------------------"
echo " Arcus CloudFoundry Install"
echo "---------------------------"
echo ""

if [ ! -e `which git` ] ; then
    echo "You must have git installed.  On ubuntu or debian, you can apt-get install git-core"
    exit 1
fi
if [ "$1" == "" ]; then
    echo "Usage: $0 <DEPLOY_TYPE> <NATS_HOST> <DOMAIN>\n\nWhere DEPLOY_TYPE is controller-<index>, db-<index>, or dea-<index> (i.e. db-0)\nand NATS_HOST is the NATS MB host and DOMAIN is the custom domain (leave blank for vcap.me)\n"
    exit 1
fi

sed -i '' "s/NATS_HOST/$2/g" $1.yml

~/vcap/dev_setup/bin/vcap_dev_setup -a -c $1.yml -D $3
if [ "$?" != "0" ]; then
    echo "Error during CloudFoundry installation"
    exit 1
fi

cp cf_control.sh /usr/local/bin/cf_control
chmod +x /usr/local/bin/cf_control

echo "---------------------------"
echo " Arcus CloudFoundry installation complete."
echo "  You can start your instance by using cf_control <start|stop|restart|tail>"
echo ""
