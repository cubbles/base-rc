#!/bin/sh

# source the env (created in bin/run.sh) to create a user specific environment
. /mnt/sda1/tmp/cubx.conf

# local vars
SOURCE_default='/'
TARGETDB_default='webpackage-store'
echo
echo -n "Enter store-path to replicate FROM ($SOURCE_default) > ";read SOURCE;echo ""
#
if [ -z "$SOURCE" ]; then {
    SOURCE=$SOURCE_default
}
fi
echo "Entered: $SOURCE"

echo
echo -n "Enter database to replicate TO ($TARGETDB_default) > ";read TARGETDB;echo ""
if [ -z "$TARGETDB" ]; then {
    TARGETDB=$TARGETDB_default
}
fi
echo "Entered: $TARGETDB"

##
echo
echo "- - - - - -"
echo
echo "Summary:"
echo " source (remote store-name like 'sandbox'): ${SOURCE}"
echo " target (local db like 'webpackage-store-sandbox'): ${TARGETDB}"
echo
echo -n "Ready to go? (y)";read go;echo ""
if [ ! -z "$go" ] && [ "$go" != 'y' ]; then {
	echo "Canceled."
    exit 0
}
fi
echo "go ..."
COREDATASTORE_IP=$(docker inspect -f '{{ .NetworkSettings.IPAddress }}' dev_base.coredatastore_1)
echo $COREDATASTORE_IP
replicationSource="https://replicator:webble#1@cubbles.world/${SOURCE}/_api/replicate/"
curl -H 'Content-Type: application/json' -X POST -d '{"source":"'${replicationSource}'","target":"'${TARGETDB}'", "create_target":true}' http://admin:admin@$COREDATASTORE_IP:5984/_replicate
echo "done."
