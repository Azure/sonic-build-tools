#!/bin/bash -ex

git clone https://github.com/Azure/sonic-swss sonic-swss-tests

cleanup() {
    docker rmi docker-sonic-vs:${JOB_NAME##*/}.${BUILD_NUMBER}
}

trap cleanup ERR

cd sonic-swss-tests/tests
sudo py.test -v --junitxml=tr.xml --imgname=docker-sonic-vs:${JOB_NAME##*/}.${BUILD_NUMBER}
