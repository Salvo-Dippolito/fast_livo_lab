




cd ${ros_ws_root}/src


#cloning ros opencv bridge package
git clone -b noetic https://github.com/ros-perception/vision_opencv.git

vision_bridge_cmake_file="${ros_ws_root}/src/vision_opencv/cv_bridge/CMakeLists.txt"

# set our downloaded version of ocv in the cv_bridge's cmakelists:
awk -v ver="$OPENCV_VERSION" '
    !found && /set\(_opencv_version / { sub(/set\(_opencv_version [0-9.]+\)/, "set(_opencv_version " ver ")"); found=1 }
    /find_package\(OpenCV / { sub(/find_package\(OpenCV [0-9.]+ QUIET\)/, "find_package(OpenCV " ver " QUIET)") }
    { print }
' "$vision_bridge_cmake_file" > "${vision_bridge_cmake_file}.tmp" && mv "${vision_bridge_cmake_file}.tmp" "$vision_bridge_cmake_file"

echo -e "${CY} Updated OpenCV version in $vision_bridge_cmake_file ${NC}"

# cloning livox ros driver
git clone https://github.com/Livox-SDK/livox_ros_driver.git 


# cloning vikit modules
git clone https://github.com/xuankuzcr/rpg_vikit.git

# cloning FAST-LIVO2 repo
git clone https://github.com/hku-mars/FAST-LIVO2

# they forgot to add an include in the header files
# reference: https://github.com/hku-mars/FAST-LIVO2/issues/66
file_path="${ros_ws_root}/src/FAST-LIVO2/include/IMU_Processing.h" 

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