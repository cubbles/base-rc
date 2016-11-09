#!/bin/sh

# Note:
# -----
# The bin/run.sh script dynamically writes the selected configuration at the beginning of this file.
# Therefore you can use any variable defined within the etc/*.conf file here.

# --------- functions ---------

start(){
    image="cubbles/demo-services:$CUBX_ENV_DEMOSERVICES_TAG"
    sourcesVolume=""
    if [ ${CUBX_ENV_DEMOSERVICES_CLUSTER} = "dev" ]; then
        sourcesVolume="-v $ENV_VM_MOUNTPOINT/$CUBX_ENV_DEMOSERVICES_IMAGE_LOCAL_SOURCE_FOLDER/demo-services/resources/opt/demo-services:/opt/demo-services"
    fi
    command="up $CUBX_ENV_DEMOSERVICES_CLUSTER"

    ######################
    # run
    ######################
    docker run --rm $sourcesVolume -v "/var/run/docker.sock:/var/run/docker.sock" $image $command

}

# --------- main ------------
start


