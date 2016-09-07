#!/bin/sh

# Note:
# -----
# The bin/run.sh script dynamically writes the selected configuration at the beginning of this file.
# Therefore you can use any variable defined within the etc/*.conf file here.

if [ ${CUBX_ENV_BASE_CLUSTER} = "dev" ]; then
    baseBackupFolder="$CUBX_ENV_VM_MOUNTPOINT/$CUBX_ENV_BASE_IMAGE_LOCAL_SOURCE_FOLDER/../../var"
    baseImageFolder="$CUBX_ENV_VM_MOUNTPOINT/$CUBX_ENV_BASE_IMAGE_LOCAL_SOURCE_FOLDER"
    docker run --rm -v "$baseBackupFolder:/backups" -v "$baseImageFolder/opt/base:/opt/base" -v "/var/run/docker.sock:/var/run/docker.sock" cubbles/base backup $CUBX_ENV_BASE_CLUSTER
else
    baseBackupFolder="/mnt/sda1/tmp"
    docker run --name cubbles_base --rm -v "$baseBackupFolder:/backups" -v "/var/run/docker.sock:/var/run/docker.sock" cubbles/base:$CUBX_ENV_BASE_TAG backup $CUBX_ENV_BASE_CLUSTER
fi

docker ps | grep cubbles_base
