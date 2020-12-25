#!/bin/bash -ex

cd sonic-buildimage

echo "Building docker containers for $DISTRO and $ARCH"

docker --version

USER=`id -un`
SLAVE_DIR=sonic-slave-$DISTRO

if [ ${ARCH} == 'amd64' ]; then
    SLAVE_BASE_IMAGE=${SLAVE_DIR}
else
    SLAVE_BASE_IMAGE=${SLAVE_DIR}-${ARCH}
fi

tmpfile=$(mktemp)

echo $ARCH > .arch

BLDENV=$DISTRO make -f Makefile.work sonic-slave-build | tee $tmpfile

SLAVE_BASE_TAG=$(grep "^Checking sonic-slave-base image:" $tmpfile | awk -F ':' '{print $3}')
SLAVE_TAG=$(grep "^Checking sonic-slave image:" $tmpfile | awk -F ':' '{print $3}')

echo $USER
echo $SLAVE_BASE_TAG
echo $SLAVE_TAG

docker images

mkdir -p target

docker save $SLAVE_BASE_IMAGE-$USER:$SLAVE_TAG | gzip -c > target/$SLAVE_BASE_IMAGE.gz

REGISTRY_PORT=443
REGISTRY_SERVER=sonicdev-microsoft.azurecr.io

docker tag $SLAVE_BASE_IMAGE-$USER:$SLAVE_TAG local/$SLAVE_BASE_IMAGE-$USER:latest
docker tag $SLAVE_BASE_IMAGE-$USER:$SLAVE_TAG $REGISTRY_SERVER:$REGISTRY_PORT/$SLAVE_BASE_IMAGE-$USER:latest
docker tag $SLAVE_BASE_IMAGE:$SLAVE_BASE_TAG $REGISTRY_SERVER:$REGISTRY_PORT/$SLAVE_BASE_IMAGE:latest
docker tag $SLAVE_BASE_IMAGE:$SLAVE_BASE_TAG $REGISTRY_SERVER:$REGISTRY_PORT/$SLAVE_BASE_IMAGE:$SLAVE_BASE_TAG

docker login -u $REGISTRY_USERNAME -p "$REGISTRY_PASSWD" $REGISTRY_SERVER:$REGISTRY_PORT
docker push $REGISTRY_SERVER:$REGISTRY_PORT/$SLAVE_BASE_IMAGE:latest
docker push $REGISTRY_SERVER:$REGISTRY_PORT/$SLAVE_BASE_IMAGE:$SLAVE_BASE_TAG
docker push $REGISTRY_SERVER:$REGISTRY_PORT/$SLAVE_BASE_IMAGE-$USER:latest
