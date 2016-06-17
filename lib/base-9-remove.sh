#!/bin/sh

# source the env (created in bin/run.sh) to create a user specific environment
. /mnt/sda1/tmp/cubx.conf

# local vars
ROOTDIR=$CUBX_ENV_BASE_ROOTDIR
BASEDIR=$ROOTDIR/base

# cleanup
sudo rm -r $BASEDIR
ls -l $ROOTDIR
