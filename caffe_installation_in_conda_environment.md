# Caffe installation in Conda environment

This document describes how to setup a [Conda](https://conda.io/en/latest/) environment for use with [Caffe](http://caffe.berkeleyvision.org/).

## Prerequisites

You need to have Conda installed. The recommended way of doing this is to install the [Anaconda Distribution](https://www.anaconda.com/distribution/). This was tested under Ubuntu 16.04.5 LTS with Anaconda3-2018.12-Linux-x86_64. Just download the anaconda version applicable to you and run the installer.

If you want to install the gpu version of caffe, you have to have [CUDA](https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html) and [cuDNN](https://docs.nvidia.com/deeplearning/sdk/cudnn-install/index.html) installed for this to work. The recommended way to install CUDA is to install it using the local deb repository. The recommended way to install cuDNN is to install it from a tar file.

## 1. Setting up the Conda environment
### A. Automatic setup
The easiest way to setup a Conda environment for use with Caffe is to merge this repository with the caffe folder and after that issuing the following command.

```bash
bash create_caffe_env.sh
```
The script will ask you where you want to put the Conda environment. The path you specify will be stored in the local CONDA_PATH variable. A Conda environment defined by the caffe.yml file will be created at $CONDA_PATH. This caffe.yml file contains a list of all the packages that are to be installed in the conda environment.

After this two files are created that will handle the creation and destruction of environment variables upon activation and deactivation of the Conda environment. The script gets these environment variables from the caffe_env_vars.txt file.

You could also issue the command like so.

```bash
bash create_caffe_env.sh /path/to/conda/environment
```
This way the script will not ask you where you want to put the conda environment. It will use `/path/to/conda/environment` instead.

If you open caffe_env_vars.txt, you will see the following.

```bash
CAFFE_ROOT=$CAFFE_PATH
PYTHONPATH=\$CAFFE_ROOT/python
LD_LIBRARY_PATH=\$CONDA_PREFIX/lib
```
Here CAFFE_PATH holds the path create_caffe_env.sh is in. Note that there is no backslash before $CAFFE_PATH. This means $CAFFE_PATH gets evaluated during the execution of create_Caffe_env.sh. In other words, $CAFFE_PATH gets replaced by the path to create_Caffe_env.sh. 

\\$CAFFE_ROOT does start with a backslash. Because of this $CAFFE_ROOT does not get evaluated during execution of create_Caffe_env.sh. Instead \\$CAFFE_ROOT gets replaced by $CAFFE_ROOT. $CAFFE_ROOT only gets evaluated upon activation of the conda environment. The same goes for $CONDA_PREFIX. CONDA_PREFIX is an environment variable that contains the path to the currently active environment.

If you edited caffe_env_vars.txt and you want to update the environment variables of a conda environment, just activate the conda environment in question and execute caffe_env_vars.sh.

```bash
conda activate <name of conda environment>
bash caffe_env_vars.sh
```

### B. Manual setup
#### B.1. Installing dependencies
The following steps will walk you through the process of manually setting up a conda environment for use with Caffe.

First you will have to create a new conda environment.
```bash
conda create -p /path/to/conda/environment
```
Next you will have to install the Caffe dependencies.

First we will install blas. You can choose between Atlas, Openblas and Intel MKL. This repository was made with openblas, because it is faster than Atlas and it works well on both newer and older machines with either Intel or AMD CPUs.
```bash
conda activate <name of conda environment>
conda install -c conda-forge -c defaults "blas=*=openblas"
```
There are multiple channels from which you can install Conda packages. You can prioritize channels with the -c flag. As you can see we have set conda-forge as the highest priority channel. After that defaults has the highest priority. Feel free to install packages from different channels, though there could be compatibility issues.

Now we will install the packages required to install caffe. To do this execute the following command at the directory you cloned this repository into.

```bash
conda install -c conda-forge -c defaults --file caffe_requirements.txt
```
Next we will install the dependencies for pycaffe. This is used to integrate caffe into python code.

```bash
conda install -c conda-forge -c defaults --file pycaffe_requirements.txt
```
Now that you have all caffe dependencies installed, you could export this environment to a .yml file, so you can easily recreate this environment.

```bash
conda env export > <name of yml file>.yml
```
#### B.2. Configuring environment variables.
There is a number of environment variables you have to set in order to get the most use out of your caffe installation. The most important one is LD_LIBRARY_PATH. If you do not set this one correctly, Caffe can not be installed at all. To set it, you could just export it directly from the terminal.

```bash
export LD_LIBRARY_PATH=$CONDA_PREFIX/lib
```

However, this approach requires you to set the environment variable every time you open a new terminal. Furthermore, this approach also does not allow you to set different environment variables for different conda environments.

Ideally environment variables should be set every time you activate the conda environment, and they should be unset every time you deactivate the conda environment. Luckily there is a way to accomplish this.

```bash
mkdir -p $CONDA_PREFIX/etc/conda/activate.d
mkdir -p $CONDA_PREFIX/etc/conda/deactivate.d
touch $CONDA_PREFIX/etc/conda/activate.d/env_vars.sh
touch $CONDA_PREFIX/etc/conda/deactivate.d/env_vars.sh
```

This creates two directories, activate.d and deactivate.d, and in each directory it will create a file env_vars.sh. activate.d/env_vars.sh is executed upon activation of the conda environment. Here you will export each environment variable you need. deactivate.d/env_vars.sh is executed upon deactivation of the environment. Here you will unset every variable you exported in activate.d/env_vars.sh.

`example of activate.d/env_vars.sh`
```bash
#!/bin/bash
export LD_LIBRARY_PATH=$CONDA_PREFIX/lib
export CAFFE_ROOT=/path/to/caffe/directory
export PYTHONPATH=$CAFFE_ROOT/python
```

CAFFE_ROOT is just to make navigation to the caffe directory easier. PYTHONPATH is so Python knows where to import Caffe from.

`example of deactivate.d/env_vars.sh`
```bash
#!/bin/bash
unset LD_LIBRARY_PATH
unset CAFFE_ROOT
unset PYTHONPATH
```

## 2. Installing Caffe
Now that you have setup your conda environment, you can go ahead and install Caffe. 
### A. Installation with provided Makefile and Makefile.config
If you have copied the provided Makefile, Makefile.config.cpu and Makefile.config.gpu into you Caffe directory, you should be able to install the cpu only version of caffe by executing the following commands.

```bash
cd $CAFFE_ROOT
cp Makefile.config.cpu Makefile.config
make clean
make -j8
make pycaffe
```

The -j8 flag tells make to use 8 threads. If your cpu has a different number of threads, feel free to change this number.

If you want to install the gpu version of caffe, copy Makefile.config.gpu instead. Also make sure CUDA_DIR in Makefile.config.gpu points to your CUDA installation directory.

Once you have installed caffe you can go ahead and run
```bash
make runtest -j8
make pytest
```
These tests will make sure Caffe has been installed without any problems.

### B. Installation without provided Makefile and Makefile.config
If you have not copied Makefile, Makefile.config.cpu and Makefile.config.gpu into your Caffe directory, you should edit Makefile and Makefile.config.example to enable installation of Caffe in a conda environment.

Makefile has been edited to use c++ 11 for compilation. This is required because the google protobuf version in the conda environment requires c++ 11 support. To do this edit Makefile like so.

`before`
```Makefile
# Complete build flags.
COMMON_FLAGS += $(foreach includedir,$(INCLUDE_DIRS),-I$(includedir))
CXXFLAGS += -pthread -fPIC $(COMMON_FLAGS) $(WARNINGS)
NVCCFLAGS += -ccbin=$(CXX) -Xcompiler -fPIC $(COMMON_FLAGS)
# mex may invoke an older gcc that is too liberal with -Wuninitalized
MATLAB_CXXFLAGS := $(CXXFLAGS) -Wno-uninitialized
LINKFLAGS += -pthread -fPIC $(COMMON_FLAGS) $(WARNINGS)
```
`after`
```Makefile
# Complete build flags.
COMMON_FLAGS += $(foreach includedir,$(INCLUDE_DIRS),-I$(includedir))
CXXFLAGS += -pthread -fPIC $(COMMON_FLAGS) $(WARNINGS) -std=c++11
NVCCFLAGS += -ccbin=$(CXX) -Xcompiler -fPIC $(COMMON_FLAGS) -std=c++11
# mex may invoke an older gcc that is too liberal with -Wuninitalized
MATLAB_CXXFLAGS := $(CXXFLAGS) -Wno-uninitialized
LINKFLAGS += -pthread -fPIC $(COMMON_FLAGS) $(WARNINGS) -std=c++11
```

For the changes to make to Makefile.config.example, take a look at either Makefile.config.cpu or Makefile.config.gpu. Important changes are

```Makefile
OPENCV_VERSION := 3

BLAS := open
BLAS_INCLUDE := $(CONDA_PREFIX_1)/pkgs/openblas-0.3.3-h9ac9557_1001/include
BLAS_LIB := $(CONDA_PREFIX_1)/pkgs/openblas-0.3.3-h9ac9557_1001/lib

PYTHON_LIBRARIES := boost_python37 python3.7m
PYTHON_LIB := $(CONDA_PREFIX)/lib
PYTHON_INCLUDE := $(CONDA_PREFIX)/include \
		$(CONDA_PREFIX)/include/python3.7m \
		$(CONDA_PREFIX)/lib/python3.7/site-packages/numpy/core/include \
WITH_PYTHON_LAYER := 1

INCLUDE_DIRS := $(PYTHON_INCLUDE)
LIBRARY_DIRS := $(PYTHON_LIB)
```
Most of these changes you can just copy from the provided Makefile.config.cpu or Makefile.config.gpu. However, if you chose to Manually setup your conda environment, your version and build of openblas and thus your BLAS_INCLUDE and BLAS_LIB may differ. To find your version and build of openblas, execute the following command.

```bash
conda list | grep -w openblas
```
Now look in the leftmost column for openblas. In the second  and third column, you will find the version and build of openblas respectively. Now change BLAS_INCLUDE and BLAS_LIB to the following.

```Makefile
BLAS_INCLUDE := $(CONDA_PREFIX_1)/pkgs/openblas-<version>-<build>/include
BLAS_LIB := $(CONDA_PREFIX_1)/pkgs/openblas-<version>-<build>/lib
```

Other changes to Makefile.config include:
```
CUDA_DIR := /usr/local/cuda-10.1

CUDA_ARCH := -gencode arch=compute_30,code=sm_30 \
		-gencode arch=compute_35,code=sm_35 \
		-gencode arch=compute_50,code=sm_50 \
		-gencode arch=compute_52,code=sm_52 \
		-gencode arch=compute_60,code=sm_60 \
		-gencode arch=compute_61,code=sm_61 \
		-gencode arch=compute_61,code=compute_61
```
You should not have to change CUDA_DIR if you have only one version of CUDA installed on your system. If you have multiple version of CUDA installed on your system, let CUDA_DIR point to the version you want to use for your Caffe installation.

When you have Makefile and Makefile.config configured, you should still execute the make commands described in [2.A.](#a-installation-with-provided-makefile-and-makefileconfig)
