#!/bin/bash -ex

# Build script for sonic-mgmt-framework.

[[ ! -z ${DISTRO} ]] || DISTRO=buster

# REDIS
sudo apt-get install -y redis-server
sudo sed -ri 's/^# unixsocket/unixsocket/' /etc/redis/redis.conf
sudo sed -ri 's/^unixsocketperm .../unixsocketperm 777/' /etc/redis/redis.conf
sudo sed -ri 's/redis-server.sock/redis.sock/' /etc/redis/redis.conf
sudo service redis-server start

# LIBYANG
sudo dpkg -i buildimage/target/debs/${DISTRO}/libyang*1.0.73*.deb

# Install from "requirement" files in sonic-mgmt-framework/tools/test directory.
pushd sonic-mgmt-framework/tools/test

[[ ! -f apt_requirements.txt ]] || \
    sed 's/#.*//' apt_requirements.txt | xargs -r sudo apt-get install -y

[[ ! -f python2_requirements.txt ]] || \
    sudo pip install --no-cache-dir -r python2_requirements.txt

[[ ! -f python3_requirements.txt ]] || \
    sudo pip3 install --no-cache-dir -r python3_requirements.txt

popd


# Build sonic-mgmt-common

pushd sonic-mgmt-common

NO_TEST_BINS=1 dpkg-buildpackage -rfakeroot -b -us -uc

popd

# Build sonic-mgmt-framework

pushd sonic-mgmt-framework

dpkg-buildpackage -rfakeroot -b -us -uc

popd

mkdir -p target
cp *.deb target/
