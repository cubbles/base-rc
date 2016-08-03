#!/bin/sh

# source the env (created in bin/run.sh) to create a user specific environment
. /mnt/sda1/tmp/cubx.conf

# --------- functions ---------

start(){
    if [ ${CUBX_ENV_DEMOSERVICES_CLUSTER} = "dev" ]; then
        baseImageFolder="$CUBX_ENV_VM_MOUNTPOINT/$CUBX_ENV_DEMOSERVICES_IMAGE_LOCAL_SOURCE_FOLDER"
        docker run --rm -v "$baseImageFolder/demo-services/resources/opt/demo-services:/opt/demo-services" -v "/var/run/docker.sock:/var/run/docker.sock" cubbles/demo-services logs $CUBX_ENV_DEMOSERVICES_CLUSTER
    else
        docker run --rm -v "/var/run/docker.sock:/var/run/docker.sock" cubbles/demo-services logs $CUBX_ENV_DEMOSERVICES_CLUSTER
    fi
    docker ps
}

start


