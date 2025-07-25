#!/bin/bash

set -e #exit on error

if test -n "$ros_setup"; then #pcl has been declared in the Dockerfile with ARG pcl, this checks if the variable has been declared

    # Define fancy colors
    MA='\033[0;35m'   # Magenta
    CY='\033[0;36m'      # Cyan
    OR='\033[38;5;214m' # Orange
    NC='\033[0m'           # No Color
    YE='\033[0;33m' # Yellow

    echo -e $YE
    echo "*************************************************************************"
    echo "***********************     Setting up ros_ws      **********************"
    echo "*************************************************************************"
    echo -e $NC
    
    script_path=$(dirname $(realpath $0))
    source "${script_path}/versions"
    ros_src="/home/${username}/ros_ws_tmp/src"
    ros_ws="/home/${username}/ros_ws_tmp"

    mkdir -p ${ros_src}
    sudo chown -R ${username}:${username} ${ros_ws}

    packages=(
        "ros-noetic-eigen-conversions"
        "ros-noetic-image-transport"
        "ros-noetic-compressed-image-transport"
        "ros-noetic-rviz"
    )
        #"ros-noetic-cv-bridge" can't install this with apt, we have to build it ourselves
    
    # Start installation process
    for package in "${packages[@]}"; do
        echo -e "${MA}Installing: $package...${NC}"
        if DEBIAN_FRONTEND=noninteractive sudo apt install -y $package; then
            echo -e "${CY} Successfully installed: $package${NC}"
        else
            echo -e "${OR} Warning: Failed to install $package${NC}"
        fi
    done

    echo -e "${CY} YOOOOOOO ${NC}"

    # Ensure rosdep is initialized only if it hasn't been already
    if [[ ! -f "/etc/ros/rosdep/sources.list.d/20-default.list" ]]; then
        sudo rosdep init
    else
        echo "rosdep already initialized, skipping init."
    fi
    rosdep update --rosdistro=${ros_distro}
    source /opt/ros/${ros_distro}/setup.bash

    cd ${ros_ws}
    catkin_make
    cd ${ros_src}


    #cloning ros opencv bridge package
    git clone -b noetic https://github.com/ros-perception/vision_opencv.git

    vision_bridge_cmake_file="${ros_src}/vision_opencv/cv_bridge/CMakeLists.txt"

    # set our downloaded version of ocv in the cv_bridge's cmakelists:
    awk -v ver="$OPENCV_VERSION" '
        !found && /set\(_opencv_version / { sub(/set\(_opencv_version [0-9.]+\)/, "set(_opencv_version " ver ")"); found=1 }
        /find_package\(OpenCV / { sub(/find_package\(OpenCV [0-9.]+ QUIET\)/, "find_package(OpenCV " ver " QUIET)") }
        { print }
    ' "$vision_bridge_cmake_file" > "${vision_bridge_cmake_file}.tmp" && mv "${vision_bridge_cmake_file}.tmp" "$vision_bridge_cmake_file"

    echo -e "${CY} Updated OpenCV version in $vision_bridge_cmake_file ${NC}"

    cd ../ && catkin_make --pkg cv_bridge
    source devel/setup.bash

    cd ${ros_src}
    # cloning livox ros driver
    git clone https://github.com/Livox-SDK/livox_ros_driver.git 

    # This is the new livox ros driver, supposedly for ros noetic
    # git clone https://github.com/Livox-SDK/livox_ros_driver2.git ws_livox/src/livox_ros_driver2
    # ./build.sh ROS1

    cd ../ && catkin_make --pkg livox_ros_driver
    source devel/setup.bash

    cd ${ros_src}

    # cloning vikit modules
    git clone https://github.com/xuankuzcr/rpg_vikit.git

    # cloning FAST-LIVO2 repo
    git clone https://github.com/hku-mars/FAST-LIVO2

    # they forgot to add an include in the header files
    # reference: https://github.com/hku-mars/FAST-LIVO2/issues/66
    file_path="${ros_src}/FAST-LIVO2/include/IMU_Processing.h" 

    if [[ -f "$file_path" ]]; then
        # Insert #include <fstream> at the top of the file if not already included
        if ! grep -q "#include <fstream>" "$file_path"; then
            # Insert the include at the very beginning
            sed -i '1i #include <fstream>' "$file_path"
            echo -e "${CY} Added #include <fstream> to $file_path${NC}"
        else
            echo -e "${OR} #include <fstream> is already present in $file_path ${NC}"
        fi
    else
        echo -e "${OR} File not found: $file_path ${NC}"
    fi
    rosdep update --rosdistro=${ros_distro}
    cd ../ && catkin_make

    source devel/setup.bash
    sudo chown -R ${username}:${username} ${ros_ws}

    echo -e $YE
    echo "*************************************************************************"
    echo "***********************      ros_ws done     ***********************"
    echo "*************************************************************************"
    echo -e $NC
fi




