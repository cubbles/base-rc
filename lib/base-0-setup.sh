#!/bin/sh

# source the env (created in bin/run.sh) to create a user specific environment
. /mnt/sda1/tmp/cubx.conf

# local vars
BASEDIR=$CUBX_ENV_BASE_ROOTDIR
TAG=$CUBX_ENV_BASE_TAG
# --------- functions ---------
createDir(){
    if [ ! -e $1 ]; then {
        echo "Creating $1"
        sudo mkdir $1
    }
    fi
    cd $1/..
    #ls -l
}

cloneBaseRepo(){
    if [ ! -e $1/.git ]; then {
        sudo GIT_SSL_NO_VERIFY=true git clone https://pmt.incowia.de/webble/r/base/base.git $1
        cd $1
        sudo git config http.sslVerify "false"
    }
    fi
}

setLocalInstallOnConfiguredTag(){
	echo "# Change into \"$1\""
    cd $1
    echo "# Updating local repository" ...
    sudo git reset -q --hard #reset local changes
    sudo git pull -t -q origin master
    echo "# Checkout tag $TAG ..."
    sudo git checkout -q $TAG
    echo "# Checkout tag $TAG. Done."
    sudo chmod -R 777 .
}
# --------- main ---------
createDir $BASEDIR
cloneBaseRepo $BASEDIR
setLocalInstallOnConfiguredTag $BASEDIR

