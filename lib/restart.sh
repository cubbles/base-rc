#!/bin/sh

# Note:
# -----
# The bin/run.sh script dynamically writes the selected configuration at the beginning of this file.
# Therefore you can use any variable defined within the etc/*.conf file here.

# --------- functions ----------
start() {
    if [[ -z $ENV_HOST_CONFIG_FOLDER ]]; then
        echo "   ERROR: Cubbles-Base config NOT found. Expected config folder at \"$ENV_HOST_CONFIG_FOLDER\"."
        exit 1
    fi

    service=$1
    image="$ENV_ROOT_IMAGE:$ENV_ROOT_IMAGE_TAG"
    customConfigVolume="-v $ENV_HOST_CONFIG_FOLDER:/opt/base/etc/custom"
    sourcesVolume=""
    if [[ ! -z $ENV_IMAGE_LOCAL_SOURCE_FOLDER ]]; then
        sourcesVolume="-v $ENV_VM_MOUNTPOINT/$ENV_IMAGE_LOCAL_SOURCE_FOLDER/opt/base:/opt/base"
    fi
    command="restart $service"

    ######################
    # run
    ######################
    docker run --rm $sourcesVolume $customConfigVolume -v "/var/run/docker.sock:/var/run/docker.sock" $image $command
    docker run --name cubbles_base --rm $sourcesVolume $customConfigVolume -v "/var/run/docker.sock:/var/run/docker.sock" $image ps
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
