#!/bin/bash -ex

# Run sanity tests for sonic-mgmt-framework.
# Assumes both sonic-mgmt-common and sonic-mgmt-framework repos
# are already compiled.

STATUS=0
DEBDIR=$(realpath sonic-mgmt-common/debian/sonic-mgmt-common)

pushd sonic-mgmt-framework/build/tests/rest

export CVL_SCHEMA_PATH=${DEBDIR}/usr/sbin/schema

./server.test -test.v -logtostderr || STATUS=1

popd

exit ${STATUS}
