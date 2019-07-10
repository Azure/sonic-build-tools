#!/bin/bash -ex

# Install HIREDIS
sudo dpkg -i buildimage/target/debs/stretch/libhiredis*.deb

# Install libnl3
sudo dpkg -i buildimage/target/debs/stretch/libnl-3-200_*.deb
sudo dpkg -i buildimage/target/debs/stretch/libnl-3-dev_*.deb
sudo dpkg -i buildimage/target/debs/stretch/libnl-genl-3-200_*.deb
sudo dpkg -i buildimage/target/debs/stretch/libnl-genl-3-dev_*.deb
sudo dpkg -i buildimage/target/debs/stretch/libnl-route-3-200_*.deb
sudo dpkg -i buildimage/target/debs/stretch/libnl-route-3-dev_*.deb
sudo dpkg -i buildimage/target/debs/stretch/libnl-nf-3-200_*.deb
sudo dpkg -i buildimage/target/debs/stretch/libnl-nf-3-dev_*.deb
sudo dpkg -i buildimage/target/debs/stretch/libnl-cli-3-200_*.deb
sudo dpkg -i buildimage/target/debs/stretch/libnl-cli-3-dev_*.deb

# Install common library
sudo dpkg -i common/libswsscommon_*.deb
sudo dpkg -i common/libswsscommon-dev_*.deb

# Install REDIS
sudo dpkg -i buildimage/target/debs/stretch/redis-tools_*.deb
sudo dpkg -i buildimage/target/debs/stretch/redis-server_*.deb
sudo sed -ri 's/^# unixsocket/unixsocket/' /etc/redis/redis.conf
sudo sed -ri 's/^unixsocketperm .../unixsocketperm 777/' /etc/redis/redis.conf
sudo sed -ri 's/redis-server.sock/redis.sock/' /etc/redis/redis.conf
sudo service redis-server start

pushd sairedis

./autogen.sh
fakeroot debian/rules binary-syncd-vs

popd

mkdir target
cp *.deb target/
