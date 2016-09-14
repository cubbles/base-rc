#!/bin/sh

# Author: Hd Böhlau
# This script is written to be executed within the git-bash on a windows host.
# Call this script using "./bin/run.sh"

# make sure, the user has done a cd into the bundle (otherwise relative paths do not work)
if [ ! -e bin/check-file ]; then { echo >&2 "Please cd into the bundle before running this script."; exit 1; }
fi


# --------- functions ---------
arrayContains(){
	local array=( "$1" )
	local returnValue=1
	for item in $array; do
    	if [ "$item" == "$2" ]; then {
    		returnValue=0
    	}
    	fi
	done
	echo $returnValue
}

executeCommands(){
	# for each "lib/<command>" passed, run a ssh call
	# ===============================================

	argsArray=( "$@" )
	for (( i=2; i<$#+1; i++ ));
	do
        #echo "DEBUG: ALLOWED_COMMANDS=${ALLOWED_COMMANDS[*]}"
		commandFile=${argsArray[$i-1]}
		# If this command is NOT configured as allowed command within the provided .conf file, exit this script.
		#echo "DEBUG: Number of commands configured: "${#ALLOWED_COMMANDS[@]}
		if [[ ${#ALLOWED_COMMANDS[@]} == 0 ]]; then {
			echo "  ERROR: No allowed commands configured."
			exit 1
		}
		fi

        #echo "DEBUG: arrayContains: "$(arrayContains "${ALLOWED_COMMANDS[*]}" "$commandFile")
		if [ 1 == $(arrayContains "${ALLOWED_COMMANDS[*]}" "$commandFile") ]; then {
			echo "  ERROR: Command \"$commandFile\" is NOT allowed for the selected configuration."
			echo "  ALLOWED_COMMANDS=${ALLOWED_COMMANDS[*]}"
			exit 1
		}
		fi

		# Check for the command-file to be available.
		if [[ ! -e $commandFile ]]; then {
			echo "  ERROR: File \"$commandFile\" not found."
			exit 1
		}
		fi

		# COPY customizations to the host
        # 1) docker-compose-custom.yml:
        #        To be mounted into the cubbles/base container to override the compose config.
        # 2) any other files:
        #        To be mounted into any other cubbles/base.* container to override container resources.
        #        This can be used to customize and/or patch the Cubbles-Base.
        # ============================================================================

        removeConfigCommand="sh -c 'rm -rf $CUBX_ENV_BASE_HOST_CONFIG_FOLDER'"
        # boot2docker sometimes changes the ownership of the config folder to root (*grrr*) - therefore we remove with 'sudo'
        removeConfigCommandVBOX="sh -c 'sudo rm -rf $CUBX_ENV_BASE_HOST_CONFIG_FOLDER'"
        setOwnerCommand="sh -c 'chown -R $DOCKER_REMOTE_HOST_USER:docker $CUBX_ENV_BASE_HOST_CONFIG_FOLDER'"
        setPermissionsCommand="sh -c 'chmod 740 -R $CUBX_ENV_BASE_HOST_CONFIG_FOLDER'"
        {
            #try
            if [ "$commandFile" = "lib/base/setup.sh" ];then {
                echo ">> Transferring '$CUBX_ENV_BASE_LOCAL_CONFIG_FOLDER' to host as '$CUBX_ENV_BASE_HOST_CONFIG_FOLDER'"
                if [ ! -d "$CUBX_ENV_BASE_LOCAL_CONFIG_FOLDER" ]; then
                    echo "   ERROR: Folder \"$CUBX_ENV_BASE_LOCAL_CONFIG_FOLDER\" NOT found."
                    exit 1
                fi
                if [[ ! -z $DOCKER_VBOX ]]; then
                    docker-machine ssh $DOCKER_VBOX "$removeConfigCommandVBOX"
                    docker-machine scp -r "$CUBX_ENV_BASE_LOCAL_CONFIG_FOLDER" $DOCKER_VBOX:"$CUBX_ENV_BASE_HOST_CONFIG_FOLDER"
                    docker-machine ssh $DOCKER_VBOX "$setOwnerCommand"
                    docker-machine ssh $DOCKER_VBOX "$setPermissionsCommand"
                else
                    ssh -i "$DOCKER_REMOTE_HOST_KEY" -l $DOCKER_REMOTE_HOST_USER -p $DOCKER_REMOTE_HOST_PORT $DOCKER_REMOTE_HOST_IP "$removeConfigCommand"
                    scp -i "$DOCKER_REMOTE_HOST_KEY" -r -P "$DOCKER_REMOTE_HOST_PORT" "$CUBX_ENV_BASE_LOCAL_CONFIG_FOLDER" "$DOCKER_REMOTE_HOST_USER"@"$DOCKER_REMOTE_HOST_IP":"$CUBX_ENV_BASE_HOST_CONFIG_FOLDER"
                    ssh -i "$DOCKER_REMOTE_HOST_KEY" -l $DOCKER_REMOTE_HOST_USER -p $DOCKER_REMOTE_HOST_PORT $DOCKER_REMOTE_HOST_IP "$setOwnerCommand"
                    ssh -i "$DOCKER_REMOTE_HOST_KEY" -l $DOCKER_REMOTE_HOST_USER -p $DOCKER_REMOTE_HOST_PORT $DOCKER_REMOTE_HOST_IP "$setPermissionsCommand"
                fi
            }
            fi

        } || {
            #catch
            echo "   ERROR: Setup failed."
            exit 1
        }

		# load the commandFile
		commandFileContent=$(<$commandFile)

		# concatenate .conf and the commands .sh -file
        shebang="#!/bin/sh"
        shebangAndConf="$shebang"$'\n'"$concatenatedConf"
        commandFileContent=${commandFileContent/"$shebang"/"$shebangAndConf"}

		# If this is the mount-command, ask for user credentials to mount a local directory into the $DOCKER_VBOX machine
		if [ "$commandFile" = "lib/_mount-hostdirectory.sh" ];then {
			echo "  Command \"$commandFile\" requires credentials to mount the configured host-directory"
			echo -n "  * Username: "; read username
			echo -n "  * Password: "; read -s password
			echo
			echo "  Executing command with username '$username' ..."
			# Note: The password will be passed into the cubx.conf file AND the file will be removed instantly at the end of this script.
			# I already tried at least to base64 encode and decode the password, but I didn't manage to make base64 work within the docker-vm (tinycorelinux)
			userCredentials=CUBX_ENV_HOST_USER=$username$'\n'CUBX_ENV_HOST_PW=$password
			shebangAndCredentials="$shebang"$'\n'"$userCredentials"
			commandFileContent=${commandFileContent/"$shebang"/"$shebangAndCredentials"}
			# echo $commandFileContent
		}
		fi

		#
		# execute the "lib/<command>"
		# ----------------------------
		echo ">> Executing $commandFile"
		if [[ ! -z $DOCKER_VBOX ]]; then
		    docker-machine ssh $DOCKER_VBOX "$commandFileContent"
		else
		    ssh -i "$DOCKER_REMOTE_HOST_KEY" -l $DOCKER_REMOTE_HOST_USER -p $DOCKER_REMOTE_HOST_PORT $DOCKER_REMOTE_HOST_IP "$commandFileContent"
		fi
		echo "<< Executing $commandFile ... Done."
	done
}

prepareVBox(){
    # Check state of vm
    # ===============================================
    STATUS=$(docker-machine status $DOCKER_VBOX)

    # Create docker-vm
    # ===============================================
    if [[ -z ${STATUS} ]]; then
        #echo "WARNING: docker-machine \"$DOCKER_VBOX\" does not exist"
        echo -n "Shall I create \"$DOCKER_VBOX\" as a local virtual-box? (y)";read go;echo ""
        if [ ! -z "$go" ] && [ "$go" != 'y' ]; then {
            echo "Canceled."
            exit 0
        }
        else {
            VBOX_DiskSize_default=20 # GB
            echo -n "Define the virtualbox disk-size (default: $VBOX_DiskSize_default GB) > ";read VBOX_DiskSize
            if [ -z "$VBOX_DiskSize" ]; then {
                VBOX_DiskSize=$VBOX_DiskSize_default
            }
            fi
            echo "Entered: $VBOX_DiskSize GB"
            echo ""
            VBOX_DiskSize=$(($VBOX_DiskSize * 1000)) # docker-machine expects the number in MB
            docker-machine create --driver virtualbox --virtualbox-disk-size $VBOX_DiskSize $DOCKER_VBOX
            docker-machine env $DOCKER_VBOX  > /dev/null 2>&1
        }
        fi
    fi

    # Start docker-vm
    # ===============================================
    STATUS=$(docker-machine status $DOCKER_VBOX)
    if [ ${STATUS} != "Running" ]; then
        # echo "docker-machine start ..."
        docker-machine start $DOCKER_VBOX
        docker-machine env $DOCKER_VBOX
        docker-machine regenerate-certs -f $DOCKER_VBOX
    fi


    # Show docker-machine states
    # ===============================================
    echo "=================================================="
    docker-machine ls | grep "NAME\|$DOCKER_VBOX"
    echo "=================================================="
    echo
}

prepareConfiguration(){
	#
	# Provide the configuration (default + custom)
	# ===============================================
    DEFAULT_CONF="etc/default/default.conf"
	defaultConf=$(cat $DEFAULT_CONF)
    # source the default configuration to have it available within this script too
    . $DEFAULT_CONF

	customConf=""
	if [[ ("${1#*'.conf'}" != "$1") && ( -e $1 ) ]]; then {
		customConf=$(cat $1)
		# source the custom configuration to have it available within this script too
		. $1
	}
	else {
		echo $'\n'"  ERROR: Expected an existing \"*.conf\" File."
		exit 1
	}
	fi

	#
	# Concat default.conf and the parameter provided <custom>.conf files
	# ... to add it at the beginning of each command .sh file
	# ===============================================
    # echo -n "> Creating file \"$ENV_TARGET\" ... "
	concatenatedConf="$defaultConf"$'\n\n\n'"$customConf"
}

# ------- main ---------
if [ $# -ge 2 ]; then {
    prepareConfiguration $@

    if [[ ! -z $DOCKER_VBOX ]] && [[ ! -z $DOCKER_REMOTE_HOST_IP ]]; then {
        echo "Configuration Error: Expecting \$DOCKER_VBOX OR \$DOCKER_REMOTE_HOST_* config to be available."
        exit 1
    }
    fi

    # If we operate on a VirtualBox based docker host ...
    if [[ ! -z $DOCKER_VBOX ]]; then {
        echo "Operating on virtual-box \"$DOCKER_VBOX\""
        prepareVBox $@
    }
    else {
        echo "Operating on remote host with IP \"$DOCKER_REMOTE_HOST_IP\""
    }
    fi

    # execute 1..n commands passed as arguments
	executeCommands $@
	exit 0
}
fi

echo
echo "Info:"
echo "------------"
echo "This script requires a configuration file and 1..n command file(s)."
echo "The commands will be executed on the configured (docker-) host."
echo
echo "Usage:"
echo "-----"
echo "$0 etc/<.conf> lib/<.sh> [lib/<.sh> ...]"