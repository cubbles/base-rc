#!/bin/sh

# Author: Hd Böhlau
# This script is written to be executed within the git-bash on a windows host.
# Call this script using "./bin/run.sh"

# make sure, the user has done a cd into the bundle (otherwise relative paths do not work)
if [ ! -e bin/check-file ]; then { echo >&2 "Please cd into the bundle before running this script."; exit 1; }
fi

DEFAULT_CONF="etc/default/default.conf"

# source the default configuration to have it available within this script too
. $DEFAULT_CONF


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
	#
	# Prepare conf file (must be sourced within the command scripts)
	# ===============================================

	defaultConf=$(cat $DEFAULT_CONF)
	customConf=""
	if [[ ("${1#*'.conf'}" != "$1") && ( -e $1 ) ]]; then {
		customConf=$(cat $1)
		# source the default configuration to have it available within this script too
		. $1
	}
	else {
		echo $'\n'"  ERROR: Expected an existing \"*.conf\" File."
		exit 1
	}
	fi

	#
	# Start a docker-vm
	# ===============================================
	echo "Operating on docker-machine \"$DOCKER_VM\""
	STATUS=$(docker-machine status $DOCKER_VM)
	echo "(docker-machine status: $STATUS)"
	if [ ${STATUS} != "Running" ]; then
		echo "docker-machine start ..."
	  	docker-machine start $DOCKER_VM
	  	echo "(docker-machine status $DOCKER_VM: $STATUS)"
	fi

	#
	# Concat default.conf and the parameter provided *.conf files
	# ... and write it as file into the docker-vm
	# ===============================================
	ENV_TARGET="/mnt/sda1/tmp/cubx.conf"
    # echo -n "> Creating file \"$ENV_TARGET\" ... "
	conf="$defaultConf"$'\n\n\n'"$customConf"

	# escape double quotes as; otherwise you miss the within the written file
	replace=\"
	replacement="\\\""
	conf=${conf//"$replace"/"$replacement"}

	# write the file
	command="sudo sh -c 'echo \""$conf"\" > $ENV_TARGET'"
	docker-machine ssh $DOCKER_VM "$command"
	echo "Done."
	#docker-machine ssh $DOCKER_VM "cat $ENV_TARGET"


	#
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
		if [ 1 == !$(arrayContains "${ALLOWED_COMMANDS[*]}" "$commandFile") ]; then {
			echo "  ERROR: Command \"$commandFile\" is NOT allowed for the selected configuration."
			echo "  ALLOWED_COMMANDS=${ALLOWED_COMMANDS[*]}"
			exit 1
		}
		fi

		# Check for command-file to be available.
		if [[ ! -e $commandFile ]]; then {
			echo "  ERROR: File \"$commandFile\" not found."
			exit 1
		}
		fi
		commandFileContent=$(<$commandFile)
		# If this is the mount-command, ask for user credentials to mount a local directory into the $DOCKER_VM machine
		if [ "$commandFile" = "lib/_mount-hostdirectory.sh" ];then {
			echo "  Command \"$commandFile\" requires credentials to mount the configured host-directory"
			echo -n "  * Username: "; read username
			echo -n "  * Password: "; read -s password
			echo
			# Note: The password will be passed into the cubx.conf file AND the file will be removed instantly at the end of this script.
			# I already tried at least to base64 encode and decode the password, but I didn't manage to make base64 work within the docker-vm (tinycorelinux)
			userCredentials=CUBX_ENV_HOST_USER=$username$'\n'CUBX_ENV_HOST_PW=$password
			replace="#!/bin/sh"
			replacement="#!/bin/sh"$'\n'$userCredentials
			commandFileContent=${commandFileContent/"$replace"/"$replacement"}
			# echo $commandFileContent
		}
		fi

		#
		# execute the "lib/<command>"
		# ----------------------------
		echo ">> Executing $commandFile"
		docker-machine ssh $DOCKER_VM "$commandFileContent"
		echo "<< Executing $commandFile ... Done."
	done

	#
	# remove cubx.conf
	# ================
	# echo -n "< Removing file \"$ENV_TARGET\" ... "
	command="sudo sh -c 'rm $ENV_TARGET'"
	docker-machine ssh $DOCKER_VM "$command"
	echo "Done."
}


# ------- main ---------
if [ $# -ge 2 ]; then {
	executeCommands $@
	exit 0
}
fi

echo "Purpose: This script requires a configuration file and 1..n commands to run within a docker-vm running on your local host."
echo "Usage: $0 etc/<customConfFile> lib/<command> [lib/<command> ...]" >&2
exit 1
