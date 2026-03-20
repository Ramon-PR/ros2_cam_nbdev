#!/bin/zsh

# This script will run from the parent folder
# It will create a ROS 2 workspace inside the project folder (PARENT_PATH)
#   - with the name provided as the first argument, or 'new_ros2_ws' if no argument is given.
# 
# It can also create a ROS2 project if the workspace name is an absolute path


# Look for the parent directory of this script
# which should be the root of the project 
SCRIPT_PATH="${BASH_SOURCE[0]:-$0}"
DIR_SCRIPT=$(cd "$(dirname "$SCRIPT_PATH")" && pwd -P)
PARENT_PATH="$DIR_SCRIPT/.."

cd "$PARENT_PATH"

# Assign the first argument ($1) to ws_name.
# If $1 is empty, use 'new_ros2_ws' as the default.
ws_name=${1:-new_ros2_ws}

# If the workspace exists, exit
[[ -d "$ws_name/src" ]] && print "ROS 2 workspace $ws_name already exists. Skipping creation." && exit 0

# If the workspace doesn't exist, create it
print "Creating ROS 2 workspace: $ws_name"    
mkdir -p "$ws_name/src"

# Initialize the workspace with colcon
print "Building ROS 2 workspace"
cd $ws_name
colcon build


