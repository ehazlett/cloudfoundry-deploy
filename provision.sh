#!/bin/sh

if [ "$1" != "" ]; then
    VCAP_DOMAIN=$1
fi

VCAP_USER=vagrant
DOMAIN=${VCAP_DOMAIN:=cf.int}
#export VCAP_REPO_BASE=https://github.com/arcus-io
export VCAP_REPO_BASE=git://github.com/arcus-io

# common config
if [ -e "/etc/.configured" ] ; then
    echo "VM appears configured ; not provisioning"
    exit 0
fi

echo ":: Setting up common configuration"
echo ":: Using domain $DOMAIN"

# configure local hosts
if [ "`grep controller /etc/hosts`" = "" ]; then
    echo "10.10.10.200 controller.$DOMAIN" >> /etc/hosts
fi

# update apt
apt-get -yqq update 2>&1 > /dev/null
apt-get -yqq install build-essential vim screen python-setuptools python-dev supervisor expat zlib1g zlib1g-dev tk bzip2 gettext libcurl4-openssl-dev libssh-dev
easy_install pip > /dev/null 2>&1

# install latest git
if [ ! -e "/usr/local/bin/git" ]; then
    wget http://git-core.googlecode.com/files/git-1.8.1.1.tar.gz -O git.tar.gz
    tar zxf git.tar.gz
    cd git-* && ./configure && make install
fi

# configure local git for post buffer errors
git config --global http.postBuffer 1048576000

# clone cloudfoundry-deploy repo
if [ ! -e "cloudfoundry-deploy" ]; then
    git clone https://github.com/ehazlett/cloudfoundry-deploy.git
fi

CWD=$PWD
echo ":: Configuring Arcus Cloud"
cd cloudfoundry-deploy
if [ ! -e "/home/$VCAP_USER/cloudfoundry/.deployments" ]; then
    # install CF
    sudo -H -u $VCAP_USER /usr/bin/sudo /bin/bash deploy.sh $DOMAIN
    if [ "$?" = "0" ]; then
        chmod +x /usr/local/bin/cf_control
    else
        exit 1
    fi
fi

# configure cloudfoundry
echo "[program:vcap-services-redis]
autostart=true
stopsignal=TERM
command=/home/$VCAP_USER/cloudfoundry/.deployments/vcap/deploy/redis/2.6.2/bin/redis-server /home/$VCAP_USER/cloudfoundry/.deployments/vcap/config/services_redis.conf --daemonize no" > /etc/supervisor/conf.d/vcap-services-redis.conf

supervisorctl update
sudo -H -u $VCAP_USER /usr/bin/sudo cf_control start cloud_controller
sudo -H -u $VCAP_USER /usr/bin/sudo cf_control start uaa
sudo -H -u $VCAP_USER /usr/bin/sudo cf_control start health_manager
if [ "`grep 'uaa:' /home/$VCAP_USER/cloudfoundry/.deployments/vcap/config/uaa.yml`" = "" ]; then
    echo "uaa:
  uris: [ uaa.$DOMAIN, login.$DOMAIN ]
    " >> /home/$VCAP_USER/cloudfoundry/.deployments/vcap/config/uaa.yml
fi
sed -i "s/redirect-uri:.*/redirect-uri: http:\/\/uaa.$DOMAIN\/redirect\/vmc,https:\/\/uaa.$DOMAIN\/redirect\/vmc/g" /home/$VCAP_USER/cloudfoundry/.deployments/vcap/config/uaa.yml

sudo -H -u $VCAP_USER /usr/bin/sudo cf_control restart cloud_controller
sudo -H -u $VCAP_USER /usr/bin/sudo cf_control restart uaa

# mark instance as configured
#touch /etc/.configured
echo ":: Configuration complete"

exit 0
