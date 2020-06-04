#!/bin/bash -ex

DISTRO=buster

# Install HIREDIS
sudo dpkg -i buildimage/target/debs/${DISTRO}/libhiredis*.deb

# Install REDIS
sudo apt-get install -y liblua5.1-0 lua-bitop lua-cjson
sudo dpkg -i buildimage/target/debs/${DISTRO}/redis-tools_*.deb
sudo dpkg -i buildimage/target/debs/${DISTRO}/redis-server_*.deb
sudo sed -ri 's/^# unixsocket/unixsocket/' /etc/redis/redis.conf
sudo sed -ri 's/^unixsocketperm .../unixsocketperm 777/' /etc/redis/redis.conf
sudo sed -ri 's/redis-server.sock/redis.sock/' /etc/redis/redis.conf
sudo service redis-server start

#Install libyang
sudo dpkg -i buildimage/target/debs/${DISTRO}/libyang*.deb

pushd sonic-mgmt-framework

dpkg-buildpackage -rfakeroot -b -us -uc

popd

mkdir -p target
cp *.deb target/

