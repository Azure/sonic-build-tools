#!/bin/bash -ex

cd sonic-buildimage

echo "Building docker containers"

docker --version

USER=`id -un`
CONFIGURED_ARCH=amd64
SLAVE_DIR=sonic-slave-$DISTRO
CONFIGURED_ARCH=${CONFIGURED_ARCH} j2 ${SLAVE_DIR}/Dockerfile.j2 > ${SLAVE_DIR}/Dockerfile
SLAVE_BASE_TAG=$(sha1sum ${SLAVE_DIR}/Dockerfile | awk '{print substr($1,0,11);}')
SLAVE_TAG=$(cat ${SLAVE_DIR}/Dockerfile.user ${SLAVE_DIR}/Dockerfile | sha1sum | awk '{print substr($1,0,11);}')

echo $USER
echo $SLAVE_BASE_TAG
echo $SLAVE_TAG

BLDENV=$DISTRO make sonic-slave-build

docker images

mkdir -p target

docker save sonic-slave-$DISTRO-$USER:$SLAVE_TAG | gzip -c > target/sonic-slave-$DISTRO.gz

REGISTRY_PORT=443
REGISTRY_SERVER=sonicdev-microsoft.azurecr.io

docker tag sonic-slave-$DISTRO-$USER:$SLAVE_TAG local/sonic-slave-$DISTRO-$USER:latest
docker tag sonic-slave-$DISTRO-$USER:$SLAVE_TAG $REGISTRY_SERVER:$REGISTRY_PORT/sonic-slave-$DISTRO-$USER:latest
docker tag sonic-slave-$DISTRO:$SLAVE_BASE_TAG $REGISTRY_SERVER:$REGISTRY_PORT/sonic-slave-$DISTRO:latest

docker login -u $REGISTRY_USERNAME -p "$REGISTRY_PASSWD" $REGISTRY_SERVER:$REGISTRY_PORT
docker push $REGISTRY_SERVER:$REGISTRY_PORT/sonic-slave-$DISTRO:latest
docker push $REGISTRY_SERVER:$REGISTRY_PORT/sonic-slave-$DISTRO-$USER:latest
