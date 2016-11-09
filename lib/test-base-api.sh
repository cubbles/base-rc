#!/bin/sh

# Note:
# -----
# The bin/run.sh script dynamically writes the selected configuration at the beginning of this file.
# Therefore you can use any variable defined within the etc/*.conf file here.

# --------- functions ----------
start(){
    if [[ -z $ENV_HOST_CONFIG_FOLDER ]]; then
        echo "   ERROR: Cubbles-Base config NOT found. Expected config folder at \"$ENV_HOST_CONFIG_FOLDER\"."
        exit 1
    fi

    env="BASE_AUTH_DATASTORE_ADMINCREDENTIALS=$1"
    command="test-base-api"
    network="cubbles_default"

    image="$ENV_ROOT_IMAGE:$ENV_ROOT_IMAGE_TAG"
    customConfigVolume="-v $ENV_HOST_CONFIG_FOLDER:/opt/base/etc/custom"
    sourcesVolume=""
    if [[ ! -z $ENV_IMAGE_LOCAL_SOURCE_FOLDER ]]; then
        sourcesVolume="-v $ENV_VM_MOUNTPOINT/$ENV_IMAGE_LOCAL_SOURCE_FOLDER/opt/base:/opt/base"
    fi
    # run the base container, connect it to the cubbles network, execute the command and remove it immediately
    docker run --name cubbles_base --rm $sourcesVolume $customConfigVolume -e $env --net $network -v "/var/run/docker.sock:/var/run/docker.sock" $image $command
}

# --------- main ----------
echo
CREDENTIALS_default="admin:admin"
if [ ${COMMAND_USE_DEFAULTS} == "true" ]; then {
    CREDENTIALS=$CREDENTIALS_default
    echo "INFO: Using DEFAULT credentials for coredatastore access [$CREDENTIALS]."
    echo
}
else {
    echo -n "Provide admin credentials for coredatastore access (default: $CREDENTIALS_default) > ";read CREDENTIALS
    if [ -z "$CREDENTIALS" ]; then {
        CREDENTIALS=$CREDENTIALS_default
    }
    fi
    echo "Entered: $CREDENTIALS"
}
fi

start $CREDENTIALS