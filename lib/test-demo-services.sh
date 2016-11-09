#!/bin/sh

# Purpose: Trigger the Base-container to run the demo-services tests.
# Note: This requires Base AND DemoServices to be up.

# Note:
# -----
# The bin/run.sh script dynamically writes the selected configuration at the beginning of this file.
# Therefore you can use any variable defined within the etc/*.conf file here.

if [[ -z $ENV_HOST_CONFIG_FOLDER ]]; then
    echo "   ERROR: Cubbles-Base config NOT found. Expected config folder at \"$ENV_HOST_CONFIG_FOLDER\"."
    exit 1
fi

command="test-demo-services_couchdb"
network1="cubbles_default"
network2="cubbles_base.gateway"

image="$ENV_ROOT_IMAGE:$ENV_ROOT_IMAGE_TAG"
customConfigVolume="-v $ENV_HOST_CONFIG_FOLDER:/opt/base/etc/custom"
sourcesVolume=""
if [[ ! -z $ENV_IMAGE_LOCAL_SOURCE_FOLDER ]]; then
    sourcesVolume="-v $ENV_VM_MOUNTPOINT/$ENV_IMAGE_LOCAL_SOURCE_FOLDER/opt/base:/opt/base"
fi
# run the base container, connect it to the cubbles network, execute the command and remove it immediately
docker run --rm $sourcesVolume $customConfigVolume --net $network1 --net $network2 -v "/var/run/docker.sock:/var/run/docker.sock" $image $command
