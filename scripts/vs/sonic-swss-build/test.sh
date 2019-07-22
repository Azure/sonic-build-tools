#!/bin/bash -ex

cleanup() {
    sudo ip -all netns delete
}

mkdir -p scripts/vs/sonic-swss-build/debs
cp *.deb scripts/vs/sonic-swss-build/debs
cp sairedis/*.deb scripts/vs/sonic-swss-build/debs
cp common/*.deb scripts/vs/sonic-swss-build/debs
cp utilities/*.deb scripts/vs/sonic-swss-build/debs

docker load < buildimage/target/docker-sonic-vs.gz

pushd scripts/vs/sonic-swss-build
mkdir -p docker-sonic-vs/debs
sudo mount --bind debs docker-sonic-vs/debs
docker build --squash --no-cache -t docker-sonic-vs docker-sonic-vs
sudo umount docker-sonic-vs/debs
popd

docker save docker-sonic-vs | gzip -c > buildimage/target/docker-sonic-vs.gz

trap cleanup ERR

pushd swss/tests
sudo py.test -v --junitxml=tr.xml
