#!/bin/bash -ex

git clone https://github.com/Azure/sonic-swss sonic-swss-tests

cd sonic-swss-tests/tests
sudo py.test -v --junitxml=tr.xml
