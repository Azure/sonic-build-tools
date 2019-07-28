#!/bin/bash -ex

cleanup() {
    sudo ip -all netns delete
}

trap cleanup ERR

pushd swss/tests
sudo py.test -v --junitxml=tr.xml --imgname=docker-sonic-vs:${JOB_NAME##*/}.${BUILD_NUMBER}
