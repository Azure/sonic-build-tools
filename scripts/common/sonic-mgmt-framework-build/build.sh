#!/bin/bash -ex

# Build script for sonic-mgmt-framework.
# Assumes sonic-mgmt-common is already cloned & built.
# Dependencies of sonic-mgmt-common would have been installed already.
# Only sonic-mgmt-framework dependencies will have to be installed here.

pushd sonic-mgmt-framework

dpkg-buildpackage -rfakeroot -b -us -uc

popd

mkdir -p target
cp sonic-mgmt-framework*.deb target/
