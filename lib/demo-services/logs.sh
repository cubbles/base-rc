#!/bin/sh

# Note:
# -----
# The bin/run.sh script dynamically writes the selected configuration at the beginning of this file.
# Therefore you can use any variable defined within the etc/*.conf file here.

if [ ${CUBX_ENV_DEMOSERVICES_CLUSTER} = "dev" ]; then
    baseImageFolder="$CUBX_ENV_VM_MOUNTPOINT/$CUBX_ENV_DEMOSERVICES_IMAGE_LOCAL_SOURCE_FOLDER"
    docker run --rm -v "$baseImageFolder/demo-services/resources/opt/demo-services:/opt/demo-services" -v "/var/run/docker.sock:/var/run/docker.sock" cubbles/demo-services logs $CUBX_ENV_DEMOSERVICES_CLUSTER
else
    docker run --rm -v "/var/run/docker.sock:/var/run/docker.sock" cubbles/demo-services logs $CUBX_ENV_DEMOSERVICES_CLUSTER
fi

docker ps
