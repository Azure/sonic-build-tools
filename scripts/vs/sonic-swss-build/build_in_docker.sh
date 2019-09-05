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

# Install libteam
sudo apt-get install -y libdbus-1-3
sudo dpkg -i buildimage/target/debs/stretch/libteam5_*.deb
sudo dpkg -i buildimage/target/debs/stretch/libteamdctl0_*.deb
sudo dpkg -i buildimage/target/debs/stretch/libteam-utils_*.deb
sudo dpkg -i buildimage/target/debs/stretch/libteam-dev_*.deb

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
