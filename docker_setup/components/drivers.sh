#!/usr/bin/bash
set -e

if [ -n "$drivers" ]; then

    # Define fancy colors
    MA='\033[0;35m'   # Magenta
    CY='\033[0;36m'      # Cyan
    OR='\033[38;5;214m' # Orange
    NC='\033[0m'           # No Color
    YE='\033[0;33m' # Yellow
    
    echo -e $YE
    echo "*************************************************************************"
    echo "********************** Installing integrated grapghic card drivers *********************"
    echo "*************************************************************************"
    echo -e $NC

    #installing intel integrated graphics drivers for lattepanda, this works because there is ubuntu24 in the host machine with correctly configured drivers
    # reference: https://github.com/openvinotoolkit/openvino_notebooks/discussions/540
    DEBIAN_FRONTEND=noninteractive apt install -y \
        software-properties-common \
        gpg-agent \
        wget \

    wget -qO - https://repositories.intel.com/graphics/intel-graphics.key |
    sudo apt-key add -
    sudo apt-add-repository \
        'deb [arch=amd64] https://repositories.intel.com/graphics/ubuntu focal main'

    
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        intel-opencl-icd \
        intel-level-zero-gpu level-zero \
        intel-media-va-driver-non-free libmfx1

    # DEBIAN_FRONTEND=noninteractive sudo apt install -y \
    #     software-properties-common \
    #     gpg-agent \
    #     wget \

    # wget -qO - https://repositories.intel.com/graphics/intel-graphics.key |
    # sudo apt-key add -
    # sudo apt-add-repository \
    # 'deb [arch=amd64] https://repositories.intel.com/graphics/ubuntu focal main'
    
    # sudo apt-get update
    # DEBIAN_FRONTEND=noninteractive sudo apt-get install -y \
    #     intel-opencl-icd \
    #     intel-level-zero-gpu level-zero \
    #     intel-media-va-driver-non-free libmfx1


    
    # echo "deb [trusted=yes] http://archive.ubuntu.com/ubuntu noble main universe" > /etc/apt/sources.list.d/noble.list
    # DEBIAN_FRONTEND=noninteractive apt update


    # DEBIAN_FRONTEND=noninteractive apt install -t noble --no-install-recommends -y \
    #     vainfo \
    #     libva-drm2 \
    #     intel-opencl-icd \
    #     libva-dev \
    #     intel-media-va-driver

    # echo -e "Package: *\nPin: release n=focal\nPin-Priority: 1001" > /etc/apt/preferences.d/focal
    # echo -e "Package: *\nPin: release n=noble\nPin-Priority: 500" > /etc/apt/preferences.d/noble

    # echo -e "${OR} fic broken install${NC}"
    # echo -e "${OR}${NC}"
    # apt --fix-broken install -y
    # apt install -f -y


    echo -e $YE
    echo "*************************************************************************"
    echo "********************** integrated grapghic card drivers Installed **********************"
    echo "*************************************************************************"
    echo -e $NC
fi