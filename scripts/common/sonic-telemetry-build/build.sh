#!/bin/bash -ex

# Install HIREDIS
sudo apt-get install -y libhiredis0.14 libhiredis-dev

# Install REDIS
sudo apt-get install -y redis-server
sudo sed -ri 's/^# unixsocket/unixsocket/' /etc/redis/redis.conf
sudo sed -ri 's/^unixsocketperm .../unixsocketperm 777/' /etc/redis/redis.conf
sudo sed -ri 's/redis-server.sock/redis.sock/' /etc/redis/redis.conf
sudo service redis-server start

# Install libyang
sudo dpkg -i buildimage/target/debs/buster/libyang*1.0.73*.deb

# Build sonic-mgmt-common first

pushd sonic-mgmt-common

NO_TEST_BINS=1 dpkg-buildpackage -rfakeroot -b -us -uc

popd

# Build sonic-telemetry

pushd sonic-telemetry

dpkg-buildpackage -rfakeroot -b -us -uc

popd

mkdir -p target
cp *.deb target/

