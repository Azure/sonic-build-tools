#!/bin/bash -ex

# Install HIREDIS
sudo apt-get install -y libhiredis0.14 libhiredis-dev

# Install libzmq
sudo apt-get install -y libzmq5 libzmq3-dev

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

# Install libteam
sudo apt-get install -y libdbus-1-3
sudo dpkg -i buildimage/target/debs/buster/libteam5_*.deb
sudo dpkg -i buildimage/target/debs/buster/libteamdctl0_*.deb
sudo dpkg -i buildimage/target/debs/buster/libteam-utils_*.deb
sudo dpkg -i buildimage/target/debs/buster/libteam-dev_*.deb

# Install SAIVS
sudo dpkg -i sairedis/libsaivs_*.deb
sudo dpkg -i sairedis/libsaivs-dev_*.deb
sudo dpkg -i sairedis/libsairedis_*.deb
sudo dpkg -i sairedis/libsairedis-dev_*.deb
sudo dpkg -i sairedis/libsaimetadata_*.deb
sudo dpkg -i sairedis/libsaimetadata-dev_*.deb
sudo dpkg -i sairedis/syncd-vs_*.deb

# Install common library
sudo dpkg -i common/libswsscommon_*.deb
sudo dpkg -i common/libswsscommon-dev_*.deb

pushd swss

./autogen.sh
fakeroot debian/rules binary

popd

mkdir -p target
cp *.deb target/
