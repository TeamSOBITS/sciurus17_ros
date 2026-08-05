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
    # Built from source rather than installed from apt: its install.sh also builds
    # librealsense2 and installs the udev rules the head and hand cameras need.
    "realsense_ros"
)

# Clone all packages
for ((i = 0; i < ${#ros_packages[@]}; i++)) {
    package=${ros_packages[i]}

    if [ -d ${package} ]; then
        echo "${package} already exists, skipping clone."
    else
        echo "Cloning: ${package}"
        git clone -b $ROS_DISTRO-devel https://github.com/TeamSOBITS/${package}.git
    fi

    # Check if install.sh exists in each package
    if [ -f ${package}/install.sh ]; then
        echo "Running install.sh in ${package}."
        cd ${package}
        bash install.sh
        cd ..
    fi
    # If kachaka-api, delete kachaka_grpc_ros2_bridge
    if [ ${package} == "kachaka-api" ]; then
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
    ros-$ROS_DISTRO-parallel-gripper-controller \
    ros-$ROS_DISTRO-diff-drive-controller \
    ros-$ROS_DISTRO-robot-state-publisher \
    ros-$ROS_DISTRO-xacro \
    ros-$ROS_DISTRO-urdf \
    ros-$ROS_DISTRO-angles \
    ros-$ROS_DISTRO-pluginlib \
    ros-$ROS_DISTRO-launch \
    ros-$ROS_DISTRO-rclcpp \
    ros-$ROS_DISTRO-rclcpp-components \
    ros-$ROS_DISTRO-rclpy \
    ros-$ROS_DISTRO-std-msgs \
    ros-$ROS_DISTRO-geometry-msgs \
    ros-$ROS_DISTRO-sensor-msgs \
    ros-$ROS_DISTRO-trajectory-msgs \
    ros-$ROS_DISTRO-message-filters \
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

# Download vision packages.
# realsense2_camera is not installed here: it is built from the realsense_ros
# source checkout above, together with librealsense2 and its udev rules.
sudo apt-get install -y \
    libpcl-dev \
    libopencv-dev \
    python3-numpy \
    python3-opencv \
    python3-scipy \
    ros-$ROS_DISTRO-pcl-ros \
    ros-$ROS_DISTRO-cv-bridge \
    ros-$ROS_DISTRO-image-geometry \
    ros-$ROS_DISTRO-image-transport \
    ros-$ROS_DISTRO-usb-cam

# Install Gazebo Harmonic with binaries
sudo apt-get install -y \
    ros-$ROS_DISTRO-ros-gz \
    ros-$ROS_DISTRO-gz-ros2-control \
    ros-$ROS_DISTRO-topic-tools

# Build and test tooling
sudo apt-get install -y \
    python3-pytest \
    ros-$ROS_DISTRO-ament-cmake \
    ros-$ROS_DISTRO-ament-cmake-pytest \
    ros-$ROS_DISTRO-ament-lint-auto \
    ros-$ROS_DISTRO-ament-lint-common \
    ros-$ROS_DISTRO-ament-copyright \
    ros-$ROS_DISTRO-ament-flake8 \
    ros-$ROS_DISTRO-ament-pep257

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
