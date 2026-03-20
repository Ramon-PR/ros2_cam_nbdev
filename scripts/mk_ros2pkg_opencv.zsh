#!/bin/zsh

# This script will run from the parent folder
# If a ROS2 workspace doesn't exist, it will create a ROS 2 workspace inside the project folder (PARENT_PATH)
#   - with the name provided as the first argument, or 'new_ros2_ws' if no argument is given.
# It will then create a ROS 2 package inside the ROS2 workspace
#   - with the name provided as the second argument, or default 'pkg_ros2_opencv'
#   - This package has the dependencies needed to work with OpenCV in ROS2, 
#     and to create a ROS2 node that can subscribe to image topics and process them with OpenCV.
# 
# It can also create a ROS2 project if the workspace name is an absolute path


# Look for the parent directory of this script
# which should be the root of the project 
SCRIPT_PATH="${BASH_SOURCE[0]:-$0}"
DIR_SCRIPT=$(cd "$(dirname "$SCRIPT_PATH")" && pwd -P)
PARENT_PATH="$DIR_SCRIPT/.."

cd "$PARENT_PATH"

ws_name=${1:-new_ros2_ws}
pkg_name=${2:-pkg_ros2_opencv}

dependency_list=(
    "rclpy" # ROS2 Python client library
    "sensor_msgs" # For handling image messages
    "std_msgs" # For standard message types
    "image_transport" # For efficient image transport
    "cv_bridge" # For converting between ROS images and OpenCV images
    "python3-opencv" # OpenCV library for Python
)


# If the workspace doesn't exist, create it
zsh "$PARENT_PATH/scripts/generate_ros2_ws.zsh" $ws_name

# Create the ROS 2 package with the specified dependencies
# ros2 pkg create --build-type ament_python $pkg_name --dependencies ${dependency_list[@]}
cd "$ws_name/src"

if [[ ! -d "$pkg_name" ]]; then
    echo "Package $pkg_name does not exist. Creating..."
    
    ros2 pkg create --build-type ament_python "$pkg_name" \
        --dependencies "${dependency_list[@]}"
    
    [[ $? -eq 0 ]] && echo "Package $pkg_name created successfully."
else
    echo "Package $pkg_name already exists."
fi

# Create launch folder for launch files
if [[ ! -d "$pkg_name/launch" ]]; then
    mkdir "$pkg_name/launch"
    echo "Launch folder created in $pkg_name."
else
    echo "Launch folder already exists in $pkg_name."
fi

# Create config folder for config files (.yaml files)
if [[ ! -d "$pkg_name/config" ]]; then
    mkdir "$pkg_name/config"
    echo "Config folder created in $pkg_name."
else
    echo "Config folder already exists in $pkg_name."
fi
