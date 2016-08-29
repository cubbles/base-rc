#!/bin/sh

# Purpose: Trigger the Base-container to run the demo-services tests.
# Note: This requires Base AND DemoServices to be up.

# source the env (created in bin/run.sh) to create a user specific environment
. cubx.conf

image="cubbles/base:$CUBX_ENV_BASE_TAG"
sourcesVolume=""
command="test-demo-services_couchdb"
network1="cubbles_default"
network2="cubbles_base.gateway"

if [ ${CUBX_ENV_BASE_CLUSTER} = "dev" ]; then
    image="cubbles/base"
    sourcesVolume="-v $CUBX_ENV_VM_MOUNTPOINT/$CUBX_ENV_BASE_IMAGE_LOCAL_SOURCE_FOLDER/opt/base:/opt/base"
fi
# run the base container, connect it to the cubbles network, execute the command and remove it immediately
docker run --rm $sourcesVolume --net $network1 --net $network2 -v "/var/run/docker.sock:/var/run/docker.sock" $image $command
