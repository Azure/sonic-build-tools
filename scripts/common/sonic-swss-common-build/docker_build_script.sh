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

# Install swsscommon packages for next steps of the build
sudo dpkg -i ../libswsscommon_*.deb
sudo dpkg -i ../libswsscommon-dev_*.deb

popd

# Build sairedis binaries
pushd sairedis

./autogen.sh
fakeroot debian/rules binary-syncd-vs

# Install sairedis packages for swss build
sudo dpkg -i ../libsaivs_*.deb
sudo dpkg -i ../libsaivs-dev_*.deb
sudo dpkg -i ../libsairedis_*.deb
sudo dpkg -i ../libsairedis-dev_*.deb
sudo dpkg -i ../libsaimetadata_*.deb
sudo dpkg -i ../libsaimetadata-dev_*.deb
sudo dpkg -i ../syncd-vs_*.deb

popd

# Install libteam for swss build
sudo apt-get install -y libdbus-1-3
sudo dpkg -i buildimage/target/debs/buster/libteam5_*.deb
sudo dpkg -i buildimage/target/debs/buster/libteamdctl0_*.deb
sudo dpkg -i buildimage/target/debs/buster/libteam-utils_*.deb
sudo dpkg -i buildimage/target/debs/buster/libteam-dev_*.deb

pushd swss

./autogen.sh
fakeroot debian/rules binary

popd

mkdir -p target
cp *.deb target/
