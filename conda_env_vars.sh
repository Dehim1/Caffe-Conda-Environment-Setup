#!/bin/bash
#Abort if any command fails.
set -e
set -o pipefail
if [[ $0 != $BASH_SOURCE ]]; then
	echo "do not use '.' or 'source'. use './' or 'bash' instead."
else
	CAFFE_PATH=$(dirname "$(readlink -f "$0")")

	#This portion of the script is to create and destroy the needed environment variables upon activation and deactivation of the conda environment.
	mkdir -p $CONDA_PREFIX/etc/conda/activate.d
	mkdir -p $CONDA_PREFIX/etc/conda/deactivate.d

	rm -f $CONDA_PREFIX/etc/conda/activate.d/env_vars.sh
	rm -f $CONDA_PREFIX/etc/conda/deactivate.d/env_vars.sh

	#script gets called upon activation
	touch $CONDA_PREFIX/etc/conda/activate.d/env_vars.sh
	#script gets called upon deactivation
	touch $CONDA_PREFIX/etc/conda/deactivate.d/env_vars.sh

	while read -r var; do   
		#Upon activation save old environment variables to temporary OLD variables.
		echo "export OLD_${var%%=*}=\$${var%%=*}" >> $CONDA_PREFIX/etc/conda/activate.d/env_vars.sh
		#Upon activation set new environment variables
		eval echo "export ${var}" >> $CONDA_PREFIX/etc/conda/activate.d/env_vars.sh
	
		#Upon deactivation set environment variables back to original value stored in temporary OLD variables.
		echo "export ${var%%=*}=\$OLD_${var%%=*}" >> $CONDA_PREFIX/etc/conda/deactivate.d/env_vars.sh
		#Upon deactivation unset temporary environment variables.
		echo "unset OLD_${var%%=*}" >> $CONDA_PREFIX/etc/conda/deactivate.d/env_vars.sh
	done <$CAFFE_PATH/conda_env_vars.txt
fi
