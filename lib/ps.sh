#!/bin/sh

# Note:
# -----
# The bin/run.sh script dynamically writes the selected configuration at the beginning of this file.
# Therefore you can use any variable defined within the etc/*.conf file here.

if [[ -z $ENV_HOST_CONFIG_FOLDER ]]; then
    echo "   ERROR: Cubbles-Base config NOT found. Expected config folder at \"$ENV_HOST_CONFIG_FOLDER\"."
    exit 1
fi

image="$ENV_ROOT_IMAGE:$ENV_ROOT_IMAGE_TAG"
customConfigVolume="-v $ENV_HOST_CONFIG_FOLDER:/opt/base/etc/custom"
sourcesVolume=""
if [[ ! -z $ENV_IMAGE_LOCAL_SOURCE_FOLDER ]]; then
    sourcesVolume="-v $ENV_VM_MOUNTPOINT/$ENV_IMAGE_LOCAL_SOURCE_FOLDER/opt/base:/opt/base"
fi
command="ps"

######################
# run
######################
docker run --name cubbles_base --rm $sourcesVolume $customConfigVolume -v "/var/run/docker.sock:/var/run/docker.sock" $image $command
