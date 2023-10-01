#!/bin/bash -ex

# Install Redis
sudo pip install Pympler==0.8
sudo apt-get install -y redis-server
sudo sed -i 's/notify-keyspace-events ""/notify-keyspace-events AKE/' /etc/redis/redis.conf
sudo sed -ri 's/^# unixsocket/unixsocket/' /etc/redis/redis.conf
sudo sed -ri 's/^unixsocketperm .../unixsocketperm 777/' /etc/redis/redis.conf
sudo sed -ri 's/redis-server.sock/redis.sock/' /etc/redis/redis.conf
sudo service redis-server restart

# Install libnl3
sudo dpkg -i buildimage/target/debs/buster/libnl-3-200_*.deb
sudo dpkg -i buildimage/target/debs/buster/libnl-3-dev_*.deb
sudo dpkg -i buildimage/target/debs/buster/libnl-genl-3-200_*.deb
sudo dpkg -i buildimage/target/debs/buster/libnl-genl-3-dev_*.deb
sudo dpkg -i buildimage/target/debs/buster/libnl-route-3-200_*.deb
sudo dpkg -i buildimage/target/debs/buster/libnl-route-3-dev_*.deb
sudo dpkg -i buildimage/target/debs/buster/libnl-nf-3-200_*.deb
sudo dpkg -i buildimage/target/debs/buster/libnl-nf-3-dev_*.deb
sudo dpkg -i buildimage/target/debs/buster/libnl-cli-3-200_*.deb
sudo dpkg -i buildimage/target/debs/buster/libnl-cli-3-dev_*.deb

sudo dpkg -i libswsscommon_*.deb
sudo dpkg -i python-swsscommon_*.deb

cd sonic-swss-common

sudo ./tests/tests && redis-cli FLUSHALL && pytest
