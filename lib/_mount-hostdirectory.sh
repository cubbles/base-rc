#!/bin/sh

# Note:
# -----
# The bin/run.sh script dynamically writes the selected configuration at the beginning of this file.
# Therefore you can use any variable defined within the etc/*.conf file here.

############# functions #############

mountFolder () {
    # http://tinycorelinux.net/faq.html#samba
    cd /mnt/sda1
    if [ ! -e /mnt/sda1/filesystems-4.2.9-tinycore.tcz ]; then {
        lib=http://tinycorelinux.net/7.x/x86/tcz/filesystems-4.2.9-tinycore.tcz
        echo -n "Installing \"$lib\"..."
        sudo curl $lib -o filesystems-4.2.9-tinycore.tcz > /dev/null 2>&1
        echo " Done."
    }
    fi
    tce-load -i /mnt/sda1/filesystems-4.2.9-tinycore.tcz > /dev/null

    sudo mkdir -p $2
    sudo mount -t cifs $1 $2 -o user=$3,pass=$4
}


############# main script #############

# check config
if [ -z $ENV_VM_MOUNTPOINT_LOCALLY_SHARED_FOLDER ];then {
		echo "   ERROR: Passed config contains no value for \"ENV_VM_MOUNTPOINT_LOCALLY_SHARED_FOLDER\".";
		exit 1;
	}
fi
if [ -z $ENV_VM_MOUNTPOINT ];then {
		echo "   ERROR: Passed config contains no value for \"ENV_VM_MOUNTPOINT\".";
		exit 1;
	}
fi

# Already mounted?
doMount=false
if [ "$(ls -A "$ENV_VM_MOUNTPOINT" >> /dev/null 2>&1)" ];then {
		echo "   INFO: Folder not empty. Assume, it is already mounted."
		echo "Folder content: $(ls -A $ENV_VM_MOUNTPOINT)"
		echo "$(ls -A $ENV_VM_MOUNTPOINT)"
		echo
		echo "Folder should be emtpy? Maybe you need to ..."
		echo " 1) ssh into the machine \n 2) remove locally created files from the folder ($ rm -rf <file or folder>)"
		echo " 2) remove local files from the folder ($ sudo rm -rf <file or folder>)"
		echo
		exit 0;
	}
	else {
		echo "   Going to mount '$ENV_VM_MOUNTPOINT_LOCALLY_SHARED_FOLDER' as user '$ENV_HOST_USER' into '$ENV_VM_MOUNTPOINT'"
		mountFolder $ENV_VM_MOUNTPOINT_LOCALLY_SHARED_FOLDER $ENV_VM_MOUNTPOINT $ENV_HOST_USER $ENV_HOST_PW
	}
fi