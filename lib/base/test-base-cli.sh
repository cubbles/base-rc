#!/bin/sh

# source the env (created in bin/run.sh) to create a user specific environment
. cubx.conf

# --------- functions ----------
start(){
    env="BASE_AUTH_DATASTORE_ADMINCREDENTIALS=$1"
    image="cubbles/base:$CUBX_ENV_BASE_TAG"
    sourcesVolume=""
    command="base-cli-test"
    network="cubbles_default"

    if [ ${CUBX_ENV_BASE_CLUSTER} = "dev" ]; then
        image="cubbles/base"
        sourcesVolume="-v $CUBX_ENV_VM_MOUNTPOINT/$CUBX_ENV_BASE_IMAGE_LOCAL_SOURCE_FOLDER/base/resources/opt/base:/opt/base"
    fi
    # run the base container, connect it to the cubbles network, execute the command and remove it immediately
    docker run --name cubbles_base --rm $sourcesVolume -e $env --net $network -v "/var/run/docker.sock:/var/run/docker.sock" $image $command
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
    echo -n "Provide admin credentials for coredatastore access (default: $CREDENTIALS_default) > ";read CREDENTIALS
    if [ -z "$CREDENTIALS" ]; then {
        CREDENTIALS=$CREDENTIALS_default
    }
    fi
    echo "Entered: $CREDENTIALS"
}
fi

start $CREDENTIALS