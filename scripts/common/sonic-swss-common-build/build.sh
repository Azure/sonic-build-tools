#!/bin/bash -ex

# Install SWIG
sudo dpkg -i buildimage/target/debs/stretch/swig3.0_*.deb

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

pushd sonic-swss-common

./autogen.sh
fakeroot debian/rules binary

popd

mkdir target
cp *.deb target/

