#!/bin/sh
# Note:
# -----
# The bin/run.sh script dynamically writes the selected configuration at the beginning of this file.
# Therefore you can use any variable defined within the etc/*.conf file here.

# --------- functions ---------

start(){
    replSource=$1
    replTarget=$2
    replWebpackages=$3
    replContinuously=$4
    replUser=$5
    replUserPw=$6
    replSourceCredentials=$7
    replSourceCredentials=""
    if [ ! -z "$7" ]; then {
        replSourceCredentials="-r $7"
    }
    fi

    image="cubbles/base:$CUBX_ENV_BASE_TAG"
    sourcesVolume=""
    network="cubbles_default"
    command="add-replication $replSource $replTarget"
    [[ ${replWebpackages} != "all" ]] && command="$command -w $replWebpackages"
    [[ ${replContinuously} == "true" ]] && command="$command -c"
    command="$command -u $replUser -p $replUserPw $replSourceCredentials -a"
echo $command
    if [ ${CUBX_ENV_BASE_CLUSTER} = "dev" ]; then
        image="cubbles/base"
        sourcesVolume="-v $CUBX_ENV_VM_MOUNTPOINT/$CUBX_ENV_BASE_IMAGE_LOCAL_SOURCE_FOLDER/opt/base:/opt/base"
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
CONTINUOUSLY_default='false'
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
echo -n "Replicate continuously (default: $CONTINUOUSLY_default) > ";read CONTINUOUSLY
if [ -z "$CONTINUOUSLY" ] || [ "$CONTINUOUSLY" != 'true' ]; then {
    CONTINUOUSLY=$CONTINUOUSLY_default
}
fi
echo "Entered: $CONTINUOUSLY"

echo
echo -n "Enter an array of webpackages to be replicated (example: pack-a@1.0,pack-b@1.1], leave blank to replicate all webpackages) > ";read WEBPACKAGES
WEBPACKAGES=${WEBPACKAGES// /} #remove spaces
if [ -z "$WEBPACKAGES" ]; then {
    WEBPACKAGES="all"
}
fi
echo "Entered: $WEBPACKAGES"

echo
echo -n "If required, please enter credentials for the replication source (example: 'user:pass'; leave blank if not required) > ";read SOURCE_CREDENTIALS
SOURCE_CREDENTIALS=${SOURCE_CREDENTIALS// /} #remove spaces
if [ -z "$SOURCE_CREDENTIALS" ]; then {
    SOURCE_CREDENTIALS=""
}
fi
echo "Entered: $SOURCE_CREDENTIALS"

##
echo
echo "- - - - - -"
echo "Summary:"
echo " source: ${SOURCE}"
echo " target: ${TARGET}"
echo " webpackages: ${WEBPACKAGES}"
echo " continuously: ${CONTINUOUSLY}"
if [ ! -z "$SOURCE_CREDENTIALS" ]; then {
    echo " source-credentials: ***:***"
}
fi
echo
echo -n "Ready to go? (y)";read go;echo ""
if [ ! -z "$go" ] && [ "$go" != 'y' ]; then {
	echo "Canceled."
    exit 0
}
fi

start $SOURCE $TARGET $WEBPACKAGES $CONTINUOUSLY admin admin $SOURCE_CREDENTIALS
