#!/bin/bash -ex

cleanup() {
    sudo ip -all netns delete
}

cp *.deb buildimage/target/debs/stretch/
cp sairedis/*.deb buildimage/target/debs/stretch/
cp common/*.deb buildimage/target/debs/stretch/
cp utilities/*.deb buildimage/target/debs/stretch/

pushd buildimage/platform/vs
mkdir -p docker-sonic-vs/debs
mkdir -p docker-sonic-vs/files
mkdir -p docker-sonic-vs/python-debs
mkdir -p docker-sonic-vs/python-wheels
sudo mount --bind ../../target/debs/stretch docker-sonic-vs/debs
sudo mount --bind ../../target/files/stretch docker-sonic-vs/files
sudo mount --bind ../../target/python-debs docker-sonic-vs/python-debs
sudo mount --bind ../../target/python-wheels docker-sonic-vs/python-wheels
docker load < ../../target/docker-config-engine-stretch.gz
docker build --squash --no-cache -t docker-sonic-vs docker-sonic-vs
sudo umount docker-sonic-vs/debs
sudo umount docker-sonic-vs/files
sudo umount docker-sonic-vs/python-debs
sudo umount docker-sonic-vs/python-wheels
popd

docker save docker-sonic-vs | gzip -c > buildimage/target/docker-sonic-vs.gz

trap cleanup ERR

pushd swss/tests
sudo py.test -v
