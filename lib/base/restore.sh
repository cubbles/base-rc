#!/bin/sh

# Note:
# -----
# The bin/run.sh script dynamically writes the selected configuration at the beginning of this file.
# Therefore you can use any variable defined within the etc/*.conf file here.

# Mount the volumes from the 'base.coredatastore' -container into the 'base' container.
#  Doing so, the 'base' container gets access to the couch database folder
coreDataStoreContainer='"'$CUBX_ENV_BASE_CLUSTER'_base.coredatastore_1"'

# An example backup file ...
# Tip: Just name your backup-file like this and you can use this script without modification.
backupFile="base.coredatastore_volume.tar.gz"

if [ ${CUBX_ENV_BASE_CLUSTER} = "dev" ]; then
    baseBackupFolder="$CUBX_ENV_VM_MOUNTPOINT/$CUBX_ENV_BASE_IMAGE_LOCAL_SOURCE_FOLDER/../../var"
    baseImageFolder="$CUBX_ENV_VM_MOUNTPOINT/$CUBX_ENV_BASE_IMAGE_LOCAL_SOURCE_FOLDER"
    # run the restore
    docker run --rm -v "$baseBackupFolder:/backups" --volumes-from=$coreDataStoreContainer -v "$baseImageFolder/opt/base:/opt/base" cubbles/base restore $CUBX_ENV_BASE_CLUSTER $backupFile
else
    baseBackupFolder="/var/tmp"
    # run the restore
    docker run --name cubbles_base --rm -v "$baseBackupFolder:/backups" --volumes-from=$coreDataStoreContainer cubbles/base:$CUBX_ENV_BASE_TAG restore $CUBX_ENV_BASE_CLUSTER $backupFile
fi

# show base processes
docker ps | grep cubbles_base

