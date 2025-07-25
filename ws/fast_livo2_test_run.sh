#!/bin/bash

current_dir=`pwd -P`
script_dir="$( cd "$(dirname "$0")" ; pwd -P )"
# The script name, without '_run' and the extension
container_name=$(basename "$0" | cut -d '.' -f 1 | sed 's/_run$//')

# Check if the container exists (even stopped)
if [ "`docker ps -aqf "name=${container_name}"`" == "" ]; then
    echo "The container ${container_name} does not exist." 2>&1
    echo "Please verify and eventually rename this script with the same name as the container." 2>&1
    exit 1
fi

# Check if the container is running
if [ "`docker ps -qf "name=${container_name}"`" == "" ]; then
    echo "Starting previously stopped container..."
    docker start "${container_name}"
fi

# Run ROS setup script on first exec
INIT_FLAG="${current_dir}/.ros_ws_initialized"
ROS_SETUP_SCRIPT="${current_dir}/${container_name}_move_back_dirs.sh"

guest_username="percro_drone"  # <<< Assign guest_username inside the script

if ! docker exec "${container_name}" test -f "${INIT_FLAG}"; then
    echo "Running ROS workspace setup..."
    docker exec "${container_name}" bash <<EOF
cp -ar /home/${guest_username}/ws_tmp/. /home/${guest_username}/ws
cp -ar /home/${guest_username}/ros_ws_tmp/. /home/${guest_username}/ros_ws
# rm -rf /home/${guest_username}/ws_tmp/
# rm -rf /home/${guest_username}/ros_ws_tmp/
EOF
    touch ${INIT_FLAG}
else
    echo "ROS workspace already set up. Skipping."
fi

# Join the container's interactive shell
docker exec -it "${container_name}" bash
