#!/bin/bash -ex

pushd sonic-ztp

dpkg-buildpackage -rfakeroot -b -us -uc

popd

mkdir -p target
cp *.deb target/

