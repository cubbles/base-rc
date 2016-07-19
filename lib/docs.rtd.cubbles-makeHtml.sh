#!/bin/sh

# source the env (created in bin/run.sh) to create a user specific environment
. /mnt/sda1/tmp/cubx.conf

############# functions #############

runDockerSphinx () {
    docker run --name sphinx-doc  -t -v $1:/doc ddidier/sphinx-doc sudo $2 $3
}

############# main script #############

# make sure docs -folder is defined
if [ -z "$CUBX_ENV_CUBBLES_DOCS_FOLDER" ]; then {
  	echo "ERROR: Please provide env 'CUBX_ENV_CUBBLES_DOCS_FOLDER'"
	exit 1
	}
fi

# make sure, the docs folder is not empty
if [ ! "$(ls -A "$CUBX_ENV_CUBBLES_DOCS_FOLDER")" ];then {
	echo " ERROR: Expected Folder $CUBX_ENV_CUBBLES_DOCS_FOLDER to be available.";
	echo "        Did you mount your host directory?";
	exit 1;
	}
fi

command="make html"
echo
echo
echo "Going to start sphinx-doc on '$CUBX_ENV_CUBBLES_DOCS_FOLDER' with command '$command'"
echo
runDockerSphinx $CUBX_ENV_CUBBLES_DOCS_FOLDER $command
echo "Done."
