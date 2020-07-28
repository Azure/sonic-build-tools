#!/bin/bash


# The cert path in the slave
SLAVE_CERT_PATH=/tmp/certs

# The cert path in the build agent
NFS_CERT_PATH=/nfs/build/test-certs

# The sonic signing key in the slave
SONIC_SIGNING_KEY="${SLAVE_CERT_PATH}/signing.key"

# The sonic signing certificate in the salve
SONIC_SIGNING_CERT="${SLAVE_CERT_PATH}/signing.cert"

# The sonic ca certificate in the salve
SONIC_CA_CERT="${SLAVE_CERT_PATH}/ca.cert"

# Override build varables
SONIC_OVERRIDE_BUILD_VARS="SIGNING_KEY=${SONIC_SIGNING_KEY} SIGNING_CERT=${SONIC_SIGNING_CERT} CA_CERT=${SONIC_CA_CERT}"

# Override slave mount options
DOCKER_BUILDER_MOUNT="$(pwd):/sonic -v ${NFS_CERT_PATH}:${SLAVE_CERT_PATH}"

