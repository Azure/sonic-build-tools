#!/bin/bash -x

sudo sed -i 's/notify-keyspace-events ""/notify-keyspace-events AKE/' /etc/redis/redis.conf
sudo service redis-server start

sudo dpkg -i libswsscommon_*.deb
sudo dpkg -i python-swsscommon_*.deb

pushd sonic-swss-common

sudo ./tests/tests

redis-cli FLUSHALL
py.test tests

popd
