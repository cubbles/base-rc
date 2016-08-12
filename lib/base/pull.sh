#!/bin/sh

# source the env (created in bin/run.sh) to create a user specific environment
. cubx.conf

image="cubbles/base:$CUBX_ENV_BASE_TAG"
sourcesVolume=""
if [ ${CUBX_ENV_BASE_CLUSTER} = "dev" ]; then
    image="cubbles/base"
    sourcesVolume="-v $CUBX_ENV_VM_MOUNTPOINT/$CUBX_ENV_BASE_IMAGE_LOCAL_SOURCE_FOLDER/base/resources/opt/base:/opt/base"
fi
command="pull $CUBX_ENV_BASE_CLUSTER"

######################
# run
######################
docker run --name cubbles_base --rm $sourcesVolume -v "/var/run/docker.sock:/var/run/docker.sock" $image $command
docker ps | grep cubbles_base
