#!/bin/bash
#
# Arcus CloudFoundry installation
#  (c) arcus.io 2012

PROJECT_DIR=`pwd`

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
