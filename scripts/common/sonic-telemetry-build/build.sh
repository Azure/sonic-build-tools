#!/bin/bash -ex

# Build script for sonic-telemetry.
# Assumes sonic-mgmt-common is already cloned & built.

# Install HIREDIS
sudo dpkg -i buildimage/target/debs/stretch/libhiredis*.deb

# Build sonic-telemetry

pushd sonic-telemetry

dpkg-buildpackage -rfakeroot -b -us -uc

popd

mkdir -p target
cp *.deb target/
