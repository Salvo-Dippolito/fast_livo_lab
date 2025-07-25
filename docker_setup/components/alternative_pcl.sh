#!/bin/bash
set -e #exit on error

if test -n "$pcl"; then #pcl has been declared in the Dockerfile with ARG pcl, this checks if the variable has been declared
    script_path=$(dirname $(realpath $0))
    source "${script_path}/versions"

    YE='\033[0;33m' # Yellow
    NC='\033[0m' # No Color
    echo -e $YE
    echo "*************************************************************************"
    echo "***********************  Installing PCL Libraries  **********************"
    echo "*************************************************************************"
    echo -e $NC

    tar xvfj pcl-pcl-${PCL_VERSION}.tar.gz
    
    cd pcl-pcl-${PCL_VERSION} && mkdir build && cd build

    cmake -DCMAKE_BUILD_TYPE=Release ..

    make -j$(nproc)

    make install


    echo -e $YE
    echo "*************************************************************************"
    echo "***********************  PCL Libraries Installed  ***********************"
    echo "*************************************************************************"
    echo -e $NC
fi