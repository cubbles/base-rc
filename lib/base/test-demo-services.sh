#!/bin/sh

# Purpose: Trigger the Base-container to run the demo-services tests.
# Note: This requires Base AND DemoServices to be up.

# Note:
# -----
# The bin/run.sh script dynamically writes the selected configuration at the beginning of this file.
# Therefore you can use any variable defined within the etc/*.conf file here.

if [[ -z $CUBX_ENV_BASE_HOST_CONFIG_FOLDER ]]; then
    echo "   ERROR: Cubbles-Base config NOT found. Expected config folder at \"$CUBX_ENV_BASE_HOST_CONFIG_FOLDER\"."
    exit 1
fi

command="test-demo-services_couchdb"
network1="cubbles_default"
network2="cubbles_base.gateway"

image="cubbles/base:$CUBX_ENV_BASE_TAG"
customConfigVolume="-v $CUBX_ENV_BASE_HOST_CONFIG_FOLDER:/opt/base/etc/custom"
sourcesVolume=""
if [[ ! -z $CUBX_ENV_BASE_IMAGE_LOCAL_SOURCE_FOLDER ]]; then
    sourcesVolume="-v $CUBX_ENV_VM_MOUNTPOINT/$CUBX_ENV_BASE_IMAGE_LOCAL_SOURCE_FOLDER/opt/base:/opt/base"
fi
# run the base container, connect it to the cubbles network, execute the command and remove it immediately
docker run --rm $sourcesVolume $customConfigVolume --net $network1 --net $network2 -v "/var/run/docker.sock:/var/run/docker.sock" $image $command
