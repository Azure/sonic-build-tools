#!/bin/bash -xe

#install libevent_2
sudo apt-get -y purge libevent-dev
sudo dpkg -i target/debs/stretch/libevent_2.*.deb

#install HIREDIS
sudo dpkg -i target/debs/stretch/libhiredis*.deb

#install libswsscommon
sudo dpkg -i target/debs/stretch/libswsscommon_*.deb
sudo dpkg -i target/debs/stretch/libswsscommon-dev_*.deb

pushd sonic-stp

./autogen.sh
dpkg-buildpackage -rfakeroot -b -us -uc

popd
mkdir -p target
cp *.deb target/
