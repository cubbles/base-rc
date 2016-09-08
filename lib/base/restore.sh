#!/bin/sh

# Note:
# -----
# The bin/run.sh script dynamically writes the selected configuration at the beginning of this file.
# Therefore you can use any variable defined within the etc/*.conf file here.

# We mount the volumes from the 'base.coredatastore' -container into the 'base' container.
#  Doing so, the 'base' container gets access to the couch database folder
coreDataStoreContainer="cubbles_base.coredatastore_1"

image="cubbles/base:$CUBX_ENV_BASE_TAG"
sourcesVolume=""
if [ ${CUBX_ENV_BASE_CLUSTER} = "dev" ]; then
    sourcesVolume="-v $CUBX_ENV_VM_MOUNTPOINT/$CUBX_ENV_BASE_IMAGE_LOCAL_SOURCE_FOLDER/opt/base:/opt/base"
fi
command="restore $CUBX_ENV_BASE_CLUSTER $CUBX_ENV_BASE_RESTORE_FILENAME"

######################
# run
######################
docker run --name cubbles_base --rm $sourcesVolume -v "$CUBX_ENV_BASE_RESTORE_FOLDER:/backups" --volumes-from=$coreDataStoreContainer -v "/var/run/docker.sock:/var/run/docker.sock" $image $command

# show base processes
docker ps | grep cubbles_base

