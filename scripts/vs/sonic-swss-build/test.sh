#!/bin/bash -ex

cleanup() {
    docker rmi docker-sonic-vs:${JOB_NAME##*/}.${BUILD_NUMBER}
}

trap cleanup ERR

pushd swss/tests
#sudo py.test -v --force-flaky --junitxml=tr.xml --imgname=docker-sonic-vs:${JOB_NAME##*/}.${BUILD_NUMBER}
sudo py.test -v --force-flaky --junitxml=tr.xml --keeptb --imgname=docker-sonic-vs:${JOB_NAME##*/}.${BUILD_NUMBER}
popd
exec ./gcov_support.sh collect_gcda_files
sudo cp buildimage/gcno.tar.gz .
exec ./gcov_support.sh generate all

cleanup
