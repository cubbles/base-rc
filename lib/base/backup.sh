#!/bin/sh

# source the env (created in bin/run.sh) to create a user specific environment
. /mnt/sda1/tmp/cubx.conf

# --------- functions ---------

start(){
    if [ ${CUBX_ENV_BASE_CLUSTER} = "dev" ]; then
        baseBackupFolder="$CUBX_ENV_VM_MOUNTPOINT/$CUBX_ENV_BASE_IMAGE_LOCAL_SOURCE_FOLDER/../../var"
        baseImageFolder="$CUBX_ENV_VM_MOUNTPOINT/$CUBX_ENV_BASE_IMAGE_LOCAL_SOURCE_FOLDER"
        docker run --rm -v "$baseBackupFolder:/backups" -v "$baseImageFolder/base/resources/opt/base:/opt/base" -v "/var/run/docker.sock:/var/run/docker.sock" cubbles/base backup $CUBX_ENV_BASE_CLUSTER
    else
        baseBackupFolder="/mnt/sda1/tmp"
        docker run --rm -v "$baseBackupFolder:/backups" -v "/var/run/docker.sock:/var/run/docker.sock" cubbles/base:$CUBX_ENV_BASE_TAG backup $CUBX_ENV_BASE_CLUSTER
    fi
    docker ps
}

start


