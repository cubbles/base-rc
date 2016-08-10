#!/bin/sh

# source the env (created in bin/run.sh) to create a user specific environment
. cubx.conf

image="cubbles/base:$CUBX_ENV_BASE_TAG"
sourcesVolume=""
command="test-base-api"
network="cubbles_default"

if [ ${CUBX_ENV_BASE_CLUSTER} = "dev" ]; then
    image="cubbles/base"
    sourcesVolume="-v $CUBX_ENV_VM_MOUNTPOINT/$CUBX_ENV_BASE_IMAGE_LOCAL_SOURCE_FOLDER/base/resources/opt/base:/opt/base"
fi
# run the base container, connect it to the cubbles network, execute the command and remove it immediately
docker run --rm $sourcesVolume --net $network -v "/var/run/docker.sock:/var/run/docker.sock" $image $command
