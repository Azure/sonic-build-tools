#!/bin/bash -ex

echo $DOCKER_IMAGE_FILE_DIR
echo $DOCKER_IMAGE_FILE
echo $DOCKER_IMAGE_TAG
echo $BUILD_NUMBER

## Login the docker image registry server
## Note: user name and password are passed from command line
docker login -u $REGISTRY_USERNAME -p "$REGISTRY_PASSWD" $REGISTRY_SERVER:$REGISTRY_PORT

## Prepare tag
docker_image_name=$(basename $DOCKER_IMAGE_FILE | cut -d. -f1)
remote_image_name=$REGISTRY_SERVER:$REGISTRY_PORT/$docker_image_name:$DOCKER_IMAGE_TAG
# timestamp="$(date -u +%Y%m%d)"
# build_version="${timestamp}.bld-$BUILD_NUMBER"
# build_remote_image_name=$REGISTRY_SERVER:$REGISTRY_PORT/$docker_image_name:$build_version

## Load docker image
docker load -i $DOCKER_IMAGE_FILE_DIR/$DOCKER_IMAGE_FILE

## Add registry information as tag, so will push as latest
## Add additional tag with build information
docker tag $docker_image_name $remote_image_name
# docker tag $docker_image_name $build_remote_image_name

## Push image to registry server
## And get the image digest SHA256
echo "Pushing $remote_image_name"
image_sha=$(docker push $remote_image_name | sed -n "s/.*: digest: sha256:\([0-9a-f]*\).*/\\1/p")
docker rmi $remote_image_name || true
echo "Image sha256: $image_sha"

# echo "Pushing $build_remote_image_name"
# docker push $build_remote_image_name
# docker rmi $build_remote_image_name || true
docker rmi $docker_image_name || true
