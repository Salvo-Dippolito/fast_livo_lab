
#!/usr/bin/bash

docker create  --privileged --memory 25458M --device /dev/dri:/dev/dri -v /dev:/dev -v /proc:/proc -v /run/udev:/run/udev -v /sys:/sys -v /tmp:/tmp --user=percro_drone -e TERM=xterm-256color -v /etc/localtime:/etc/localtime:ro -v /home/sigma/Desktop/fast_livo/docker_setup/target_bin:/home/percro_drone/bin -v /var/run/dbus/system_bus_socket:/var/run/dbus/system_bus_socket --ulimit nofile=1024:524288 -e DISPLAY=$DISPLAY -e QT_X11_NO_MITSHM=1 -v /tmp/.X11-unix:/tmp/.X11-unix:rw -v /home/sigma/.Xauthority:/home/percro_drone/.Xauthority:rw -e XDG_RUNTIME_DIR=/run/user/1000 -v /run/user/1000:/run/user/1000 --network host --ipc host --pid host  \
    -v /home/sigma/Desktop/fast_livo/workspaces_/ws:/home/percro_drone/ws -v /home/sigma/Desktop/fast_livo/workspaces_/ros_ws:/home/percro_drone/ros_ws/src  \
    --name "fast_livo2_test" \
    -it fast_livo2_test-ros-noetic
