#!/bin/bash
set -e #exit on error

if test -n "$livoxSDK"; then #pcl has been declared in the Dockerfile with ARG pcl, this checks if the variable has been declared
    script_path=$(dirname $(realpath $0))
    source "${script_path}/versions"
    
    ws_dir="/home/${username}/ws_tmp"
    sudo chown -R ${username}:${username} ${ws_dir}

    YE='\033[0;33m' # Yellow
    NC='\033[0m' # No Color
    echo -e $YE
    echo "*************************************************************************"
    echo "**********************     Installing Livox SDK     *********************"
    echo "*************************************************************************"
    echo -e $NC
    
    cd ${ws_dir}
    git clone https://github.com/Livox-SDK/Livox-SDK.git
    cd Livox-SDK/build && cmake ..
    make
    sudo make install

    # after installing the livox sdk we'll have to install the livox ros package in our ros workspace,
    # this gets done in the ros_setup.sh
    sudo chown -R ${username}:${username} ${ws_dir}

    echo -e $YE
    echo "*************************************************************************"
    echo "***********************    Livox SDK Installed    ***********************"
    echo "*************************************************************************"
    echo -e $NC
fi