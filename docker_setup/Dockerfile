ARG ros_distro=noetic

#full ROS NOetic image with gazebo and Rviz
FROM ros:${ros_distro}-ros-base

ARG ros_distro=noetic

SHELL [ "/bin/bash" ]
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV TZ Europe/Rome

COPY components/aptUpdate.sh /tmp/components/aptUpdate.sh
RUN /tmp/components/aptUpdate.sh

##################### Components #####################
# Load component versions (changes on this file will make Docker rebuild all that follows)
COPY components/versions /tmp/components/versions

# Common path for system components installed inside scripts
ENV components_path /ros_components

ARG drivers
COPY components/drivers.sh /tmp/components/drivers.sh
RUN /tmp/components/drivers.sh

COPY components/base.sh /tmp/components/base.sh
RUN /tmp/components/base.sh

ARG cuda
COPY components/cuda.sh /tmp/components/cuda.sh
RUN /tmp/components/cuda.sh

ENV PATH /usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64
ENV CUDA_HOME /usr/local/cuda

# # nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility

ARG openCV
COPY components/openCV.sh /tmp/components/openCV.sh
RUN /tmp/components/openCV.sh

ARG pcl
COPY components/pcl.sh /tmp/components/pcl.sh
RUN /tmp/components/pcl.sh

ARG username

#setting these up for userSetup.sh:

ARG uid
ARG gid 
#ARG ros_dom_id=0 not sure about this

COPY components/userSetup.sh /tmp/components/userSetup.sh
RUN /tmp/components/userSetup.sh
USER ${username}
ENV PATH "$PATH:/usr/local/bin"
ENV HOME /home/${username}
WORKDIR /home/${username}

# install all fast livo packages after user setup:
ARG sophus
COPY components/sophus.sh /tmp/components/sophus.sh
RUN /tmp/components/sophus.sh

ARG livoxSDK
COPY components/livoxSDK.sh /tmp/components/livoxSDK.sh
RUN /tmp/components/livoxSDK.sh   

ARG ros_setup
COPY components/ros_setup.sh /tmp/components/ros_setup.sh
RUN /tmp/components/ros_setup.sh

# Configure user environment
COPY target_bin/tmux.conf /home/${username}/.tmux.conf