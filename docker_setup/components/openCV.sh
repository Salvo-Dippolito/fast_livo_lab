#!/usr/bin/bash
set -e

if [ -n "$openCV" ]; then

    # Define fancy colors
    MA='\033[0;35m'   # Magenta
    CY='\033[0;36m'      # Cyan
    OR='\033[38;5;214m' # Orange
    NC='\033[0m'           # No Color
    YE='\033[0;33m' # Yellow
    
    echo -e $YE
    echo "*************************************************************************"
    echo "********************** Installing OpenCV Components *********************"
    echo "*************************************************************************"
    echo -e $NC
    script_path=$(dirname $(realpath $0))
    source "${script_path}/versions"

    # --------------------- OpenCV from source ---------------------

    # Check if the cuda module is compiled too
    if [ -n "$cuda" ]; then
        echo -e "${CY} Enabling cuda acceleration${NC}"
        ENABLE_CUDA=ON
    else
        echo -e "${CY} No cuda acceleration${NC}"
    fi

    echo -e "${CY} Removing python3-opencv   ${NC}"
    apt remove -y libopencv-dev python3-opencv

    PYTHON_VERSION=$(python3 --version | awk '{print $2}' | cut -d. -f1,2)
    echo -e "${CY} Installed python version is ${PYTHON_VERSION} ${NC}"
    echo -e "${CY} Installing necessary packages  ${NC}"

    DEBIAN_FRONTEND=noninteractive apt install --no-install-recommends -y \
        i965-va-driver \
        vainfo \
        libva-dev

    # List of packages to install
    packages=(
        "pkg-config"
        "libgtk3.0-cil-dev"
        "libavcodec-dev"
        "libavformat-dev"
        "libavutil-dev"
        "libswscale-dev"
        "libswresample-dev"
        "libx264-dev"
        "libtbb-dev"
        "libjpeg-dev"
        "libpng-dev"
        "libtiff-dev"
        "v4l-utils"
        "gstreamer1.0-plugins-base"
        "gstreamer1.0-plugins-base-apps"
        "gstreamer1.0-plugins-good"
        "gstreamer1.0-plugins-bad"
        "gstreamer1.0-plugins-ugly"
        "gstreamer1.0-tools"
        "gstreamer1.0-libav"
        "gstreamer1.0-opencv"
        "gstreamer1.0-rtsp"
        "libatlas-base-dev"
        "libopenblas64-dev"
        "libopenblas64-0-openmp"
        "aravis-tools"
        "liblapack-dev"
        "libleptonica-dev"
        "python${PYTHON_VERSION}-dev"
        "liblapacke-dev"
        "liblapacke64-dev"

    )
        # "tesseract-ocr"
        # "libtesseract-dev"
        # "libtbbmalloc2"
        # "libgtk-3-dev"

        # "libgstreamer1.0-dev"
        # "libgstreamer-plugins-base1.0-dev"
        # "libgstreamer-plugins-good1.0-dev"
        # "libgstreamer-plugins-bad1.0-dev"
        # "gstreamer1.0-vaapi"
        # "libaravis-dev"
        # "libgtkglext1-dev"
        # "libgl1-mesa-dev"
        # "libglu1-mesa-dev"
        # "qtbase5-dev"
        # "libqt5opengl5-dev"
        # "libmount-dev"
        # "libpcre3-dev"
        # "libselinux1-dev"
        # "zlib1g-dev"

    #DEBIAN_FRONTEND=noninteractive apt install -t noble -y --reinstall libmount-dev libpcre3-dev libselinux1-dev zlib1g-dev

    noble_packages=(

        
        "libgstreamer1.0-dev"
        "libgstreamer-plugins-base1.0-dev"
        "libgstreamer-plugins-good1.0-dev"
        "libgstreamer-plugins-bad1.0-dev"
        "gstreamer1.0-vaapi"
        "libaravis-dev"
        "libgtkglext1-dev"
        "libgl1-mesa-dev"
        "libglu1-mesa-dev"
        "qtbase5-dev"
        "libqt5opengl5-dev"
    )

    #"libglib2.0-dev"
    echo -e "${OR}installing noble packages $package${NC}"  
    for package in "${noble_packages[@]}"; do
        echo -e "${MA}Installing: $package...${NC}"
        if DEBIAN_FRONTEND=noninteractive apt install -t focal -y $package; then
            echo -e "${CY}Successfully installed: $package${NC}"
            apt --fix-broken install
            sudo dpkg --configure -a
        else
            echo -e "${OR}Warning: Failed to install $package${NC}"
        fi
    done

    echo -e "${OR}installing focal packages $package${NC}" 
    # Start installation process
    for package in "${packages[@]}"; do
        echo -e "${MA}Installing: $package...${NC}"
        if DEBIAN_FRONTEND=noninteractive apt install -t focal -y $package; then
            echo -e "${CY}Successfully installed: $package${NC}"
        else
            echo -e "${OR}Warning: Failed to install $package${NC}"
        fi
    done

    echo -e "${CY} Installing numpy with pip3   ${NC}"
    pip3 install numpy # not from apt, it's different! (2024-07-23)
    
    echo -e "${CY} Cloning OpenCV source directories  ${NC}"
    mkdir -p /opencv
    cd /opencv
    test -d opencv-${OPENCV_VERSION} || {
        wget -O opencv.zip https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip
        wget -O opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/${OPENCV_VERSION}.zip
        unzip opencv.zip
        unzip opencv_contrib.zip
        rm opencv.zip opencv_contrib.zip
    }
    cd opencv-${OPENCV_VERSION}

    #modify this if you need opencv for video processing
    #TO_DO: if this is enabled then you also need to download the nvidia sdk (to be matched with the cuda version on the host machine)
    #       in the docker image and link nvcuvid and nvcenc libraries to the cmake command  
    ENABLE_VIDEOACC=OFF

    mkdir -p build && cd build
    cmake   -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib-${OPENCV_CONTRIB_VERSION}/modules \
            -D CMAKE_INSTALL_PREFIX=/usr/local \
            -D ENABLE_FAST_MATH=1 \
            -D OPENCV_GENERATE_PKGCONFIG=ON \
            -D OPENCV_ENABLE_NONFREE=ON  \
            -D WITH_GTK=ON \
            -D WITH_QT=ON \
            -D WITH_TBB=ON \
            -D WITH_VA=ON \
            -D WITH_VA_INTEL=ON \
            -D WITH_CUDA=${ENABLE_CUDA:-OFF} \
            -D CUDA_ARCH_BIN=${CUDA_ARCH_BIN} \
            -D WITH_NVCUVID=${ENABLE_VIDEOACC:-OFF} \
            -D WITH_NVCUVENC=${ENABLE_VIDEOACC:-OFF} \
            -D BUILD_JPEG=ON \
            -D BUILD_OPENJPEG=ON \
            -D WITH_ARAVIS=ON  \
            -D WITH_OPENVINO=ON  \
            -D WITH_OPENNI2=OFF \
            -D WITH_EIGEN=ON  \
            -D WITH_V4L=ON \
            -D WITH_LIBV4L=ON \
            -D WITH_OPENGL=ON \
            -D OpenGL_GL_PREFERENCE=LEGACY \
            -D WITH_IPP=ON \
            -D WITH_GSTREAMER=ON \
            -D WITH_FFMPEG=ON \
            -D WITH_REALSENSE=ON  \
            -D WITH_TESSERACT=OFF\
            -D WITH_PYTHON3=ON \
            -D CMAKE_BUILD_TYPE=RELEASE \
            -D CPU_BASELINE=SSE4_2 \
            -D PYTHON3_EXECUTABLE=$(which python3) \
            -D PYTHON3_LIBRARY=/usr/lib/python${PYTHON_VERSION} \
            -D PYTHON3_INCLUDE_DIR=$(python3 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") \
            -D PYTHON3_PACKAGES_PATH=$(python3 -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())")  \
            -D BUILD_opencv_python2=OFF \
            -D BUILD_opencv_python3=ON \
            -D BUILD_PERF_TESTS=OFF \
            -D CMAKE_INCLUDE_PATH="/usr/include;/usr/include/x86_64-linux-gnu" \
            -D LAPACKE_INCLUDE_DIR="/usr/include;/usr/include/x86_64-linux-gnu" \
            -D BLAS_INCLUDE_DIR="/usr/include/x86_64-linux-gnu" \
            -D OPENCV_GENERATE_SETUPVARS=OFF \
            ..
    # OpenGL_GL_PREFERENCE=LEGACY  probably had to be added because we're working with ubuntu 20.04 and there was an issue with glvnd
    # reference: https://github.com/opencv/opencv_contrib/issues/2307
    maxproc=$(( $(nproc) < 16 ? $(nproc) : 16 ))

    echo -e "${CY} Building OpenCV:  ${NC}"
    make -j ${maxproc} #substitute this numer with the variable above if you're confident
    echo -e "${CY} Installing Libraries:  ${NC}"
    make -j ${maxproc} install
    echo -e "${CY} Updating System's shared libraries ${NC}"
    ldconfig
    rm -rf /opencv

    echo -e $YE
    echo "*************************************************************************"
    echo "********************** OpenCV Components Installed **********************"
    echo "*************************************************************************"
    echo -e $NC
fi
