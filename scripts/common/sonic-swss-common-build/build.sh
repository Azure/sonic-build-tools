#!/bin/bash -ex

# Install swig
sudo apt-get install -y swig

# Install HIREDIS
sudo apt-get install -y libhiredis0.14 libhiredis-dev

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

pushd sonic-swss-common

./autogen.sh
fakeroot debian/rules binary

popd

mkdir -p target
cp *.deb target/

