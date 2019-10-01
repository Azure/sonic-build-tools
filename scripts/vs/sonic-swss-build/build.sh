#!/bin/bash -ex

echo ${JOB_NAME##*/}.${BUILD_NUMBER}

docker login -u $REGISTRY_USERNAME -p $REGISTRY_PASSWD sonicdev-microsoft.azurecr.io:443
docker pull sonicdev-microsoft.azurecr.io:443/sonic-slave-stretch:latest
docker run --rm=true --privileged -v $(pwd):/sonic -w /sonic -i sonicdev-microsoft.azurecr.io:443/sonic-slave-stretch:latest ./scripts/vs/sonic-swss-build/build_in_docker.sh

mkdir -p scripts/vs/sonic-swss-build/debs
cp *.deb scripts/vs/sonic-swss-build/debs
cp sairedis/*.deb scripts/vs/sonic-swss-build/debs
cp common/*.deb scripts/vs/sonic-swss-build/debs
cp utilities/*.deb scripts/vs/sonic-swss-build/debs

docker load < buildimage/target/docker-sonic-vs.gz

pushd scripts/vs/sonic-swss-build
mkdir -p docker-sonic-vs/debs
sudo mount --bind debs docker-sonic-vs/debs
docker build --no-cache -t docker-sonic-vs:${JOB_NAME##*/}.${BUILD_NUMBER} docker-sonic-vs
sudo umount docker-sonic-vs/debs
popd

docker save docker-sonic-vs:${JOB_NAME##*/}.${BUILD_NUMBER} | gzip -c > buildimage/target/docker-sonic-vs.gz
