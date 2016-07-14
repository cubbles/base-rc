#!/bin/sh


# use this command to create a couchdb backup from your base-0.9 install on you local machine
# note: it requires the base to be running

docker run --rm -v "/var/tmp:/backups" --volumes-from base.coredatastore.dev debian:wheezy tar cfz /backups/base.coredatastore_volume.tar.gz /usr/local/var/lib/couchdb



