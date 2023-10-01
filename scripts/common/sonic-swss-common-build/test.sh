#!/bin/bash -ex

echo ${JOB_NAME##*/}.${BUILD_NUMBER}

docker pull sonicdev-microsoft.azurecr.io:443/sonic-slave-buster-johnar:latest
docker run --rm=true --privileged -v $(pwd):/sonic -w /sonic -i sonicdev-microsoft.azurecr.io:443/sonic-slave-buster-johnar:latest ./scripts/common/sonic-swss-common-build/docker_test_script.sh
