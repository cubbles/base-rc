#!/bin/sh

# Note:
# -----
# The bin/run.sh script dynamically writes the selected configuration at the beginning of this file.
# Therefore you can use any variable defined within the etc/*.conf file here.

image="cubbles/base:$CUBX_ENV_BASE_TAG"
sourcesVolume=""
if [ ${CUBX_ENV_BASE_CLUSTER} = "dev" ]; then
    sourcesVolume="-v $CUBX_ENV_VM_MOUNTPOINT/$CUBX_ENV_BASE_IMAGE_LOCAL_SOURCE_FOLDER/opt/base:/opt/base"
fi
command="ps $CUBX_ENV_BASE_CLUSTER"

######################
# run
######################
docker run --name cubbles_base --rm $sourcesVolume -v "/var/run/docker.sock:/var/run/docker.sock" $image $command
