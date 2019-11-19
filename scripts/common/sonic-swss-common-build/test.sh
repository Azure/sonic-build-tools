#!/bin/bash -ex

# Install Redis
sudo apt-get install -y liblua5.1-0 lua-bitop lua-cjson
sudo dpkg -i buildimage/target/debs/stretch/redis-tools_*.deb
sudo dpkg -i buildimage/target/debs/stretch/redis-server_*.deb
sudo sed -i 's/notify-keyspace-events ""/notify-keyspace-events AKE/' /etc/redis/redis.conf
sudo service redis-server start

sudo dpkg -i libswsscommon_*.deb
sudo dpkg -i python-swsscommon_*.deb

cd sonic-swss-common

sudo ./tests/tests && redis-cli FLUSHALL && pytest
