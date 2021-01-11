#!/bin/bash -ex

# Build script for sonic-mgmt-common.
# Installs all dependencies required for compiling and testing
# CVL and translib.

[[ ! -z ${DISTRO} ]] || DISTRO=buster

# REDIS
sudo apt-get install -y redis-server
sudo sed -ri 's/^# unixsocket/unixsocket/' /etc/redis/redis.conf
sudo sed -ri 's/^unixsocketperm .../unixsocketperm 777/' /etc/redis/redis.conf
sudo sed -ri 's/redis-server.sock/redis.sock/' /etc/redis/redis.conf
sudo service redis-server start

# LIBYANG
sudo dpkg -i buildimage/target/debs/${DISTRO}/libyang*1.0.73*.deb


pushd sonic-mgmt-common

dpkg-buildpackage -rfakeroot -b -us -uc

popd

mkdir -p target
cp sonic-mgmt-common*.deb target/
