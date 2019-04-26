#!/bin/bash
#Abort if any command fails.
set -e
set -o pipefail
#Beginning of script.
if [[ $0 != $BASH_SOURCE ]]; then
	echo "do not use '.' or 'source'. use './' or 'bash' instead."
else
	#CAFFE_PATH is the path to this script. CONDA_PATH is the path to the conda environment.
	CAFFE_PATH=$(dirname "$(readlink -f "$0")")
	CONDA_PATH=$1
	#repeat while CONDA_PATH is empty.	
	while [ -z "$CONDA_PATH" ]
	do
		echo "Enter Conda environment install directory. Directory must be empty or non-existent."		
		read CONDA_PATH
	done
	#Check if directory exists.
	if [ -d $CONDA_PATH ]; then
		#Check if directory is not empty.
		if [ ! -z "$(ls -A $CONDA_PATH)" ]; then
			echo "Directory is not empty."
			exit 1
		fi
	fi	
	
	#Create conda environment.
	conda env create --file $CAFFE_PATH/caffe.yml -p $CONDA_PATH
	
	#This portion of the script is to create and destroy the needed environment variables upon activation and deactivation of the conda environment.
	mkdir -p $CONDA_PATH/etc/conda/activate.d
	mkdir -p $CONDA_PATH/etc/conda/deactivate.d
	#script gets called upon activation
	touch $CONDA_PATH/etc/conda/activate.d/env_vars.sh
	#script gets called upon deactivation
	touch $CONDA_PATH/etc/conda/deactivate.d/env_vars.sh
	
	while read -r var; do   
		#Upon activation save old environment variables to temporary OLD variables.
		echo "export OLD_${var%%=*}=\$${var%%=*}" >> $CONDA_PATH/etc/conda/activate.d/env_vars.sh
		#Upon activation set new environment variables
		eval echo "export ${var}" >> $CONDA_PATH/etc/conda/activate.d/env_vars.sh
	
		#Upon deactivation set environment variables back to original value stored in temporary OLD variables.
		echo "export ${var%%=*}=\$OLD_${var%%=*}" >> $CONDA_PATH/etc/conda/deactivate.d/env_vars.sh
		#Upon deactivation unset temporary environment variables.
		echo "unset OLD_${var%%=*}" >> $CONDA_PATH/etc/conda/deactivate.d/env_vars.sh
	done <$CAFFE_PATH/conda_env_vars.txt
fi
