#!/bin/bash -ex

# Build sonic-wpa-supplicant

pushd sonic-wpa-supplicant

dpkg-buildpackage -rfakeroot -b -us -uc

popd

mkdir -p target
cp *.deb target/
