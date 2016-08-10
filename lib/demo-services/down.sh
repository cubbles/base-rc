#!/bin/sh

# source the env (created in bin/run.sh) to create a user specific environment
. cubx.conf

image="cubbles/demo-services:$CUBX_ENV_DEMOSERVICES_TAG"
sourcesVolume=""
if [ ${CUBX_ENV_DEMOSERVICES_CLUSTER} = "dev" ]; then
    sourcesVolume="-v $CUBX_ENV_VM_MOUNTPOINT/$CUBX_ENV_DEMOSERVICES_IMAGE_LOCAL_SOURCE_FOLDER/demo-services/resources/opt/demo-services:/opt/demo-services"
fi
command="down $CUBX_ENV_DEMOSERVICES_CLUSTER"

######################
# run
######################
docker run --rm $sourcesVolume -v "/var/run/docker.sock:/var/run/docker.sock" $image $command
