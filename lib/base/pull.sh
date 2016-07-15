#!/bin/sh

# source the env (created in bin/run.sh) to create a user specific environment
. /mnt/sda1/tmp/cubx.conf

# --------- functions ---------

start(){
    if [ ${CUBX_ENV_BASE_CLUSTER} = "dev" ]; then
        baseImageFolder="$CUBX_ENV_VM_MOUNTPOINT/$CUBX_ENV_BASE_IMAGE_LOCAL_SOURCE_FOLDER"
        docker run --rm -v "$baseImageFolder/base/resources/opt/base:/opt/base" -v "/var/run/docker.sock:/var/run/docker.sock" cubbles/base pull
    else
        docker run --rm -v "/var/run/docker.sock:/var/run/docker.sock" cubbles/base:$CUBX_ENV_BASE_TAG pull
    fi
    docker ps
}

start


