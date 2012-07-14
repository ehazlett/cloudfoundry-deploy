#!/bin/sh

if [ "$1" = "" ] ; then echo "Usage: `basename $0` [action]"; exit 1; fi
$HOME/cloudfoundry/vcap/dev_setup/bin/vcap_dev -n `ls ~/cloudfoundry/.deployments` $1
