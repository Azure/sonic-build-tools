#!/bin/bash -ex

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

# Install common library
sudo dpkg -i common/libswsscommon_*.deb
sudo dpkg -i common/libswsscommon-dev_*.deb

# Install REDIS
sudo apt-get install -y redis-server
sudo sed -ri 's/^# unixsocket/unixsocket/' /etc/redis/redis.conf
sudo sed -ri 's/^unixsocketperm .../unixsocketperm 777/' /etc/redis/redis.conf
sudo sed -ri 's/redis-server.sock/redis.sock/' /etc/redis/redis.conf
sudo service redis-server start

# Start rsyslog
sudo apt-get install -y rsyslog
sudo service rsyslog start

cleanup() {
    mkdir -p ../target
    sudo cp /var/log/syslog ../target/
    sudo chmod 644 ../target/syslog
}

trap cleanup ERR

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

# Re-build SWSS with the newly updated sairedis. This is important because swss is built against
# sairedis, so two things can go wrong:
#
# 1. The build can just straight up fail.
# 2. The symbol table can change, which causes bizarre runtime issues if you install the sairedis
#    debs without also updating/installing a new swss deb.
#
# FIXME: This doesn't respect the submodule pointer, which may introduce some instability that
# isn't present in the actual image build. Need a slightly better solution here. ¯\_(ツ)_/¯
pushd swss

./autogen.sh
fakeroot debian/rules binary

popd

mkdir -p target
cp *.deb target/
sudo cp /var/log/syslog target/
sudo chmod 644 target/syslog
