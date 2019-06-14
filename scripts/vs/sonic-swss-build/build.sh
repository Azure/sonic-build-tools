#!/bin/bash -x

docker run --rm=true --privileged -v $(pwd):/sonic -w /sonic -i sonic-slave-stretch-johnar ./scripts/vs/sonic-swss-build/build_in_docker.sh
