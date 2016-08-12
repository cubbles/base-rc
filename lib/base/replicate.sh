#!/bin/sh

# source the env (created in bin/run.sh) to create a user specific environment
. cubx.conf

# --------- functions ---------

start(){
    replSource=$1
    replTarget=$2
    replWebpackages=$3
    replUser=$4
    replUserPw=$5
    replContinuously=""
    if [ -z "$6" ] && [ "$6" == 'true' ]; then {
        replContinuously="-c"
    }
    fi

    image="cubbles/base:$CUBX_ENV_BASE_TAG"
    sourcesVolume=""
    network="cubbles_default"

    command="add-replication $replSource $replTarget"
    [[ ${replWebpackages} != "[]" ]] && command="$command -w $replWebpackages"
    command="$command -u $replUser -p $replUserPw $replContinuously -a"

    if [ ${CUBX_ENV_BASE_CLUSTER} = "dev" ]; then
        image="cubbles/base"
        sourcesVolume="-v $CUBX_ENV_VM_MOUNTPOINT/$CUBX_ENV_BASE_IMAGE_LOCAL_SOURCE_FOLDER/base/resources/opt/base:/opt/base"
    fi
    #echo $command
    echo "- - - - - -"
    echo "Result: "
    echo "-------"
    # run the base container, execute the command and remove it immediately
    docker run --name cubbles_base --rm $sourcesVolume --net $network -v "/var/run/docker.sock:/var/run/docker.sock" $image $command
    echo "- - - - - -"
    echo "Done. "
    echo "- - - - - -"

}


# --------- main ----------

# local vars
SOURCE_default='core'
TARGET_default='sandbox'
echo
echo -n "Enter store to replicate FROM (default: $SOURCE_default) > ";read SOURCE
#
if [ -z "$SOURCE" ]; then {
    SOURCE=$SOURCE_default
}
fi
echo "Entered: $SOURCE"

echo
echo -n "Enter store to replicate TO (default: $TARGET_default) > ";read TARGET
if [ -z "$TARGET" ]; then {
    TARGET=$TARGET_default
}
fi
echo "Entered: $TARGET"

echo
echo -n "Enter an array of webpackages to be replicated (example: [\"pack-a@1.0\", \"pack-b@1.1\"], default: []) > ";read WEBPACKAGES
WEBPACKAGES=${WEBPACKAGES// /} #remove spaces
if [ -z "$WEBPACKAGES" ]; then {
    WEBPACKAGES="[]"
}
fi
echo "Entered: $WEBPACKAGES"

##
echo
echo "- - - - - -"
echo "Summary:"
echo " source (source): ${SOURCE}"
echo " target (local target): ${TARGET}"
echo " webpackages: ${WEBPACKAGES}"
echo
echo -n "Ready to go? (y)";read go;echo ""
if [ ! -z "$go" ] && [ "$go" != 'y' ]; then {
	echo "Canceled."
    exit 0
}
fi
#replicationSource="https://replicator:webble#1@cubbles.world/${SOURCE}/_api/replicate/"
#curl -H 'Content-Type: application/json' -X POST -d '{"source":"'${replicationSource}'","target":"'${TARGET}'", "create_target":true}' http://admin:admin@$COREDATASTORE_IP:5984/_replicate
#curl -H 'Content-Type: application/json' -X POST -d '{"source":"'${replicationSource}'","target":"'${TARGET}'", "create_target":true}' http://admin:admin@$COREDATASTORE_IP:5984/_replicate
#echo "done."

start $SOURCE $TARGET $WEBPACKAGES admin admin false
