#!/bin/bash -ex

docker login -u $REGISTRY_USERNAME -p $REGISTRY_PASSWD sonicdev-microsoft.azurecr.io:443
docker run --rm=true --privileged -v $(pwd):/sonic -w /sonic -i sonic-slave-stretch-johnar ./scripts/vs/sonic-swss-build/build_in_docker.sh
