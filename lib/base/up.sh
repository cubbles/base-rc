#!/bin/sh

# Note:
# -----
# The bin/run.sh script dynamically writes the selected configuration at the beginning of this file.
# Therefore you can use any variable defined within the etc/*.conf file here.

# --------- functions ----------
start(){
    credentials=$1
    image="cubbles/base:$CUBX_ENV_BASE_TAG"
    sourcesVolume=""
    if [ ${CUBX_ENV_BASE_CLUSTER} = "dev" ]; then
        sourcesVolume="-v $CUBX_ENV_VM_MOUNTPOINT/$CUBX_ENV_BASE_IMAGE_LOCAL_SOURCE_FOLDER/opt/base:/opt/base"
    fi
    command="up $CUBX_ENV_BASE_CLUSTER -a $credentials"

    ######################
    # run
    ######################
    docker run --name cubbles_base --rm $sourcesVolume -v "/var/run/docker.sock:/var/run/docker.sock" $image $command
    docker run --name cubbles_base --rm $sourcesVolume -v "/var/run/docker.sock:/var/run/docker.sock" $image ps $CUBX_ENV_BASE_CLUSTER
}

# --------- main ----------
echo
CREDENTIALS_default="admin:admin"
if [ ${CUBX_COMMAND_USE_DEFAULTS} == "true" ]; then {
    CREDENTIALS=$CREDENTIALS_default
    echo "INFO: Using DEFAULT credentials for coredatastore access [$CREDENTIALS]."
    echo
}
else {
    echo -n "Define admin credentials for coredatastore access (default: $CREDENTIALS_default) > ";read CREDENTIALS
    if [ -z "$CREDENTIALS" ]; then {
        CREDENTIALS=$CREDENTIALS_default
    }
    fi
    echo "Entered: $CREDENTIALS"
}
fi

start $CREDENTIALS



