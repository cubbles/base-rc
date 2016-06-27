#!/bin/sh

# source the env (created in bin/run.sh) to create a user specific environment
. /mnt/sda1/tmp/cubx.conf

############# functions #############

mountFolder () {
    # http://tinycorelinux.net/faq.html#samba
    cd /mnt/sda1
    if [ ! -e /mnt/sda1/filesystems-4.2.9-tinycore.tcz ]; then {
      sudo curl http://tinycorelinux.net/7.x/x86/tcz/filesystems-4.2.9-tinycore.tcz -o filesystems-4.2.9-tinycore.tcz
     }
     fi
    tce-load -i /mnt/sda1/filesystems-4.2.9-tinycore.tcz > /dev/null

    sudo mkdir -p $2
    sudo mount -t cifs $1 $2 -o user=$3,pass=$4
}


############# main script #############

# check config
if [ -z $CUBX_ENV_VM_MOUNTPOINT_LOCALLY_SHARED_FOLDER ];then {
		echo "   ERROR: Passed config contains no value for \"CUBX_ENV_VM_MOUNTPOINT_LOCALLY_SHARED_FOLDER\".";
		exit 1;
	}
fi
if [ -z $CUBX_ENV_VM_MOUNTPOINT ];then {
		echo "   ERROR: Passed config contains no value for \"CUBX_ENV_VM_MOUNTPOINT\".";
		exit 1;
	}
fi

# Already mounted?
doMount=false
if [ "$(ls -A "$CUBX_ENV_VM_MOUNTPOINT")" ];then {
		echo "   INFO: Folder not empty. Assume, it is already mounted.";
		exit 0;
	}
	else {
		echo "   Going to mount '$CUBX_ENV_VM_MOUNTPOINT_LOCALLY_SHARED_FOLDER' as user '$CUBX_ENV_HOST_USER' into '$CUBX_ENV_VM_MOUNTPOINT'"
		mountFolder $CUBX_ENV_VM_MOUNTPOINT_LOCALLY_SHARED_FOLDER $CUBX_ENV_VM_MOUNTPOINT $CUBX_ENV_HOST_USER $CUBX_ENV_HOST_PW
	}
fi