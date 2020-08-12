#!/bin/bash -ex

echo ${JOB_NAME##*/}.${BUILD_NUMBER}

docker pull sonicdev-microsoft.azurecr.io:443/sonic-slave-buster-johnar:latest
docker run --rm=true --privileged -v $(pwd):/sonic -w /sonic -i sonicdev-microsoft.azurecr.io:443/sonic-slave-buster-johnar:latest ./scripts/common/sonic-swss-common-build/docker_build_script.sh

mkdir -p scripts/common/sonic-swss-common-build/docker-sonic-vs/debs
cp *.deb scripts/common/sonic-swss-common-build/docker-sonic-vs/debs

docker load < buildimage/target/docker-sonic-vs.gz

pushd scripts/vs/sonic-swss-common-build
docker build --no-cache -t docker-sonic-vs:${JOB_NAME##*/}.${BUILD_NUMBER} docker-sonic-vs
popd

docker save docker-sonic-vs:${JOB_NAME##*/}.${BUILD_NUMBER} | gzip -c > buildimage/target/docker-sonic-vs.gz
