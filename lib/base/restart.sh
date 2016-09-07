#!/bin/sh

# Note:
# -----
# The bin/run.sh script dynamically writes the selected configuration at the beginning of this file.
# Therefore you can use any variable defined within the etc/*.conf file here.

# --------- functions ----------
start() {
    service=$1
    image="cubbles/base:$CUBX_ENV_BASE_TAG"
    sourcesVolume=""
    if [ ${CUBX_ENV_BASE_CLUSTER} = "dev" ]; then
        image="cubbles/base"
        sourcesVolume="-v $CUBX_ENV_VM_MOUNTPOINT/$CUBX_ENV_BASE_IMAGE_LOCAL_SOURCE_FOLDER/opt/base:/opt/base"
    fi
    command="restart $CUBX_ENV_BASE_CLUSTER $service"

    ######################
    # run
    ######################
    docker run --rm $sourcesVolume -v "/var/run/docker.sock:/var/run/docker.sock" $image $command
    docker run --name cubbles_base --rm $sourcesVolume -v "/var/run/docker.sock:/var/run/docker.sock" $image ps $CUBX_ENV_BASE_CLUSTER
}

# --------- main ----------
echo
SERVICE_default="base.gateway"
echo -n "Service to be restarted (default: $SERVICE_default)  > ";read SERVICE
if [ -z "$SERVICE" ]; then {
    SERVICE=$SERVICE_default
}
fi
echo "Entered: $SERVICE"

start $SERVICE
