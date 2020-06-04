#!/bin/bash -ex

# Install HIREDIS
sudo dpkg -i buildimage/target/debs/stretch/libhiredis*.deb

# Install REDIS
sudo apt-get install -y liblua5.1-0 lua-bitop lua-cjson
sudo dpkg -i buildimage/target/debs/stretch/redis-tools_*.deb
sudo dpkg -i buildimage/target/debs/stretch/redis-server_*.deb
sudo sed -ri 's/^# unixsocket/unixsocket/' /etc/redis/redis.conf
sudo sed -ri 's/^unixsocketperm .../unixsocketperm 777/' /etc/redis/redis.conf
sudo sed -ri 's/redis-server.sock/redis.sock/' /etc/redis/redis.conf
sudo service redis-server start

# Install libyang
sudo dpkg -i buildimage/target/debs/stretch/libyang*.deb

# Clone sonic-mgmt-framework repository
git clone https://github.com/Azure/sonic-mgmt-framework

pushd sonic-telemetry

dpkg-buildpackage -rfakeroot -b -us -uc

popd

mkdir -p target
cp *.deb target/

