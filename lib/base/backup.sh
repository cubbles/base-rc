#!/bin/sh

# Note:
# -----
# The bin/run.sh script dynamically writes the selected configuration at the beginning of this file.
# Therefore you can use any variable defined within the etc/*.conf file here.

if [[ -z $CUBX_ENV_BASE_HOST_CONFIG_FOLDER ]]; then
    echo "   ERROR: Cubbles-Base config NOT found. Expected config folder at \"$CUBX_ENV_BASE_HOST_CONFIG_FOLDER\"."
    exit 1
fi

image="cubbles/base:$CUBX_ENV_BASE_TAG"
customConfigVolume="-v $CUBX_ENV_BASE_HOST_CONFIG_FOLDER:/opt/base/etc/custom"
sourcesVolume=""
if [[ ! -z $CUBX_ENV_BASE_IMAGE_LOCAL_SOURCE_FOLDER ]]; then
    sourcesVolume="-v $CUBX_ENV_VM_MOUNTPOINT/$CUBX_ENV_BASE_IMAGE_LOCAL_SOURCE_FOLDER/opt/base:/opt/base"
fi
command="backup"

######################
# run
######################
docker run --name cubbles_base --rm $sourcesVolume $customConfigVolume -v "/var/run/docker.sock:/var/run/docker.sock" $image $command