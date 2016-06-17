#!/bin/sh

# source the env (created in bin/run.sh) to create a user specific environment
. /mnt/sda1/tmp/cubx.conf

# local vars
BASEDIR=$CUBX_ENV_BASE_ROOTDIR
# --------- functions ---------

startLocalCluster(){
    cd $1
    echo $PWD
    sudo ./bin/run.sh base-cli up $CUBX_ENV_BASE_CLUSTER
}


# --------- main ---------
if [ ! -e $BASEDIR ]; then {
    echo "ERROR: Base is not available. Please run the setup-script before."
    exit 1
}
fi
startLocalCluster $BASEDIR


