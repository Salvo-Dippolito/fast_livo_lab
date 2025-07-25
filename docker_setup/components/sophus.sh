#!/bin/bash
set -e #exit on error

if test -n "$sophus"; then #pcl has been declared in the Dockerfile with ARG pcl, this checks if the variable has been declared
    script_path=$(dirname $(realpath $0))
    source "${script_path}/versions"
    YE='\033[0;33m' # Yellow
    NC='\033[0m' # No Color
    echo -e $YE
    echo "*************************************************************************"
    echo "***********************     Installing Sophus      **********************"
    echo "*************************************************************************"
    echo -e $NC
    if ["$EUID" -eq 0]; then
        echo "OH NOOOOOO"
        exit 1
    fi

    ws_dir="/home/${username}/ws_tmp"
    mkdir -p ${ws_dir}
    chown -R ${username}:${username} ${ws_dir}
    cd ${ws_dir}
    git clone https://github.com/strasdat/Sophus.git
    cd Sophus
    git checkout a621ff

    # Have to fix a source file in the Sophus library before building everything
    # reference: https://github.com/uzh-rpg/rpg_svo/issues/237

    # This is the file:
    file_path="${ws_dir}/Sophus/sophus/so2.cpp"

    if [[ ! -f "$file_path" ]]; then
        echo "File not found: $file_path"
        exit 1
    fi
    # this is the fix, we're replacing two lines:
    sed -i '/unit_complex_.real() = 1\.;/c\  unit_complex_ = std::complex<double>(1,0);' "$file_path"
    sed -i '/unit_complex_.imag() = 0\.;/d' "$file_path"

    echo "\n Replacement completed successfully.\n"

    sudo chown -R ${username}:${username} ${ws_dir}

    mkdir build && cd build && cmake ..
    make
    sudo make install

    echo -e $YE
    echo "*************************************************************************"
    echo "***********************      Sophus Installed     ***********************"
    echo "*************************************************************************"
    echo -e $NC
fi