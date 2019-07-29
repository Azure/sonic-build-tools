#!/bin/bash -ex

cleanup() {
    docker rmi docker-sonic-vs:${JOB_NAME##*/}.${BUILD_NUMBER}
}

trap cleanup ERR

pushd swss/tests
sudo py.test -v --junitxml=tr.xml --imgname=docker-sonic-vs:${JOB_NAME##*/}.${BUILD_NUMBER}
