#!/bin/bash

set -u
set -o pipefail
echo "╔══╣ Setup: SCIURUS17 KACHAKA (STARTING) ╠══╗"


# Keep track of the current directory
DIR=`pwd`
cd ..

# Download required packages for SCIURUS17 KACHAKA
ros_packages=(
    "sciurus17_description"
    "sciurus17_kachaka_description"
    "kachaka-api"
)

# Clone all packages
for ((i = 0; i < ${#ros_packages[@]}; i++)) {
    if [ -d ${ros_packages[i]} ]; then
        echo "${ros_packages[i]} already exists, skipping clone."
    else
        echo "Cloning: ${ros_packages[i]}"
        git clone -b $ROS_DISTRO https://github.com/TeamSOBITS/${ros_packages[i]}.git
    fi

    # Check if install.sh exists in each package
    if [ -f ${ros_packages[i]}/install.sh ]; then
        echo "Running install.sh in ${ros_packages[i]}."
        cd ${ros_packages[i]}
        bash install.sh
        cd ..
    fi
    # If kachaka-api, delete kachaka_grpc_ros2_bridge
    if [ ${ros_packages[i]} == "kachaka-api" ]; then
        echo "Deleting kachaka_grpc_ros2_bridge"
        rm -rf kachaka-api/ros2/kachaka_grpc_ros2_bridge
    fi
}

# Go back to previous directory
cd ${DIR}

# Download ROS packages
sudo apt-get update
sudo apt-get install -y \
    ros-$ROS_DISTRO-ros2-control \
    ros-$ROS_DISTRO-ros2-controllers \
    ros-$ROS_DISTRO-controller-manager \
    ros-$ROS_DISTRO-controller-interface \
    ros-$ROS_DISTRO-hardware-interface \
    ros-$ROS_DISTRO-joint-trajectory-controller \
    ros-$ROS_DISTRO-joint-state-broadcaster \
    ros-$ROS_DISTRO-joint-state-publisher \
    ros-$ROS_DISTRO-joint-state-publisher-gui \
    ros-$ROS_DISTRO-gripper-controllers \
    ros-$ROS_DISTRO-diff-drive-controller \
    ros-$ROS_DISTRO-robot-state-publisher \
    ros-$ROS_DISTRO-xacro \
    ros-$ROS_DISTRO-urdf \
    ros-$ROS_DISTRO-angles \
    ros-$ROS_DISTRO-pluginlib \
    ros-$ROS_DISTRO-std-msgs \
    ros-$ROS_DISTRO-geometry-msgs \
    ros-$ROS_DISTRO-sensor-msgs \
    ros-$ROS_DISTRO-trajectory-msgs \
    ros-$ROS_DISTRO-tf2 \
    ros-$ROS_DISTRO-tf2-ros \
    ros-$ROS_DISTRO-tf2-geometry-msgs \
    ros-$ROS_DISTRO-rviz2 \
    ros-$ROS_DISTRO-rviz-common \
    ros-$ROS_DISTRO-rviz-default-plugins

# Download MoveIt 2 packages
sudo apt-get install -y \
    ros-$ROS_DISTRO-moveit \
    ros-$ROS_DISTRO-moveit-configs-utils \
    ros-$ROS_DISTRO-moveit-kinematics \
    ros-$ROS_DISTRO-moveit-planners \
    ros-$ROS_DISTRO-moveit-py \
    ros-$ROS_DISTRO-moveit-ros-move-group \
    ros-$ROS_DISTRO-moveit-ros-planning-interface \
    ros-$ROS_DISTRO-moveit-ros-visualization \
    ros-$ROS_DISTRO-moveit-setup-assistant \
    ros-$ROS_DISTRO-moveit-simple-controller-manager

# Download vision packages
sudo apt-get install -y \
    libpcl-dev \
    libopencv-dev \
    ros-$ROS_DISTRO-pcl-ros \
    ros-$ROS_DISTRO-cv-bridge \
    ros-$ROS_DISTRO-image-geometry \
    ros-$ROS_DISTRO-usb-cam \
    ros-$ROS_DISTRO-realsense2-camera

# Install Gazebo Harmonic with binaries
sudo apt-get install -y \
    ros-$ROS_DISTRO-ros-gz \
    ros-$ROS_DISTRO-gz-ros2-control \
    ros-$ROS_DISTRO-topic-tools

# Install the remaining declared dependencies
rosdep install -r -y -i --from-paths .

# Set up the USB serial device name used by sciurus17_control
if [ -f sciurus17_tools/scripts/create_udev_rules ]; then
    echo "Creating udev rules for Sciurus17"
    bash sciurus17_tools/scripts/create_udev_rules || true
fi

# Reload udev rules
sudo udevadm control --reload-rules || true

# Trigger the new rules
sudo udevadm trigger || true

# Go back to previous directory
cd ${DIR}


echo "╚══╣ Setup: SCIURUS17 KACHAKA (FINISHED) ╠══╝"
