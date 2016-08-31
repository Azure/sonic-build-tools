#!/bin/bash
# Pull DOCKER_OPTS from config file
if [ -z "$DOCKER_OPTS" ];then
  source /etc/default/docker
fi

# Allow user to specify image to build
images=$*
if [ -z "$images" ];then
  for i in */; do images+="$i "; done
fi

for i in $images; do
  img=${i%/}
  echo Building image local/$img
  docker ${DOCKER_OPTS} build --no-cache -t local/$img $img || exit $?
done
