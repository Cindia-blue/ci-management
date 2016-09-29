#!/bin/bash

# vim: ts=4 sw=4 sts=4 et tw=72 :

rh_systems() {
    # Install python dependencies
    yum install -y python-{devel,virtualenv,setuptools,pip}

    # Build dependencies for Python packages
    yum install -y openssl-devel mysql-devel gcc

    # Autorelease support packages
    yum install -y xmlstarlet

    # Packer builds happen from the centos flavor images
    PACKERDIR=$(mktemp -d)
    # disable double quote checking
    # shellcheck disable=SC2086
    cd $PACKERDIR
    wget https://releases.hashicorp.com/packer/0.10.1/packer_0.10.1_linux_amd64.zip
    unzip packer_0.10.1_linux_amd64.zip -d /usr/local/bin/
    # rename packer to avoid conflicts with cracklib
    mv /usr/local/bin/packer /usr/local/bin/packer.io

    # cleanup from the installation
    # disable double quote checking
    # shellcheck disable=SC2086
    rm -rf $PACKERDIR
    # cleanup from previous install process
    if [ -d /tmp/packer ]
    then
        rm -rf /tmp/packer
    fi
}

ubuntu_systems() {
    # Install python dependencies
    apt install -y python-{dev,virtualenv,setuptools,pip}

    # Build dependencies for Python packages
    apt install -y libssl-dev libmysqlclient-dev gcc
}

all_systems() {
    echo 'No common distribution configuration to perform'
}

echo "---> Detecting OS"
ORIGIN=$(facter operatingsystem | tr '[:upper:]' '[:lower:]')

case "${ORIGIN}" in
    fedora|centos|redhat)
        echo "---> RH type system detected"
        rh_systems
    ;;
    ubuntu)
        echo "---> Ubuntu system detected"
        ubuntu_systems
    ;;
    *)
        echo "---> Unknown operating system"
    ;;
esac

# execute steps for all systems
all_systems
