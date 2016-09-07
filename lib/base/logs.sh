#!/bin/sh

# Note:
# -----
# The bin/run.sh script dynamically writes the selected configuration at the beginning of this file.
# Therefore you can use any variable defined within the etc/*.conf file here.

image="cubbles/base:$CUBX_ENV_BASE_TAG"
sourcesVolume=""
if [ ${CUBX_ENV_BASE_CLUSTER} = "dev" ]; then
    image="cubbles/base"
    sourcesVolume="-v $CUBX_ENV_VM_MOUNTPOINT/$CUBX_ENV_BASE_IMAGE_LOCAL_SOURCE_FOLDER/opt/base:/opt/base"
fi
command="logs $CUBX_ENV_BASE_CLUSTER --tail 100"

######################
# run
######################
docker run --name cubbles_base --rm $sourcesVolume -v "/var/run/docker.sock:/var/run/docker.sock" $image $command
docker ps | grep cubbles_base


