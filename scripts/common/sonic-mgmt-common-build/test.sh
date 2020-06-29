#!/bin/bash -ex

# Run sanity tests for sonic-mgmt-common.
# Assumes sonic-mgmt-common is already compiled and all dependencies
# are installed.


STATUS=0
DEBDIR=$(realpath sonic-mgmt-common/debian/sonic-mgmt-common)

# Run CVL tests

pushd sonic-mgmt-common/build/tests/cvl

CVL_SCHEMA_PATH=testdata/schema \
	./cvl.test -test.v -logtostderr || STATUS=1

popd

# Run translib tests

pushd sonic-mgmt-common/build/tests/translib

export CVL_SCHEMA_PATH=${DEBDIR}/usr/sbin/schema
export YANG_MODELS_PATH=${DEBDIR}/usr/models/yang

./db.test -test.v -logtostderr || STATUS=1

./translib.test -test.v -logtostderr || STATUS=1

popd

exit ${STATUS}
