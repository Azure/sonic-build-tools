#!/bin/bash -x

# Install Redis
sudo dpkg -i buildimage/target/debs/stretch/redis-tools_*.deb
sudo dpkg -i buildimage/target/debs/stretch/redis-server_*.deb
sudo sed -i 's/notify-keyspace-events ""/notify-keyspace-events AKE/' /etc/redis/redis.conf
sudo service redis-server start

sudo dpkg -i libswsscommon_*.deb
sudo dpkg -i python-swsscommon_*.deb

pushd sonic-swss-common

sudo ./tests/tests

redis-cli FLUSHALL
py.test tests

popd
