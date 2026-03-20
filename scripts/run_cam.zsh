#! /bin/zsh
# Let's put this script with the other bash scripts

# 1. Check the camera is connected and accessible
# 2. Source ros2
# 3. Compile the ROS2 package
# 4. Source the local ROS2 workspace
# 5. Add the local site-packages to PYTHONPATH, (from my .venv)
# 6. Run the ROS2 node 


# 0. Get the directories
ws_name=${1:-ros2_ws}
pkg_name=${2:-pkg_cam}
node_name=${3:-camera_setup}

# Get the script directory
BASH_SCRIPT=$(realpath "$0")
SCRIPTS_DIR=$(dirname "$BASH_SCRIPT")
# Get project directory
ROOT_DIR=$(dirname "$SCRIPTS_DIR")
echo "Root directory: $ROOT_DIR"
# Get ros2 ws directory
ROS2_WS_DIR="$ROOT_DIR/$ws_name"
echo "ROS2 workspace directory: $ROS2_WS_DIR"
# Get package directory
ROS2_PKG_DIR="$ROS2_WS_DIR/src/$pkg_name"
echo "ROS2 package directory: $ROS2_PKG_DIR"


# 1. Check if there is /dev/video0, otherwise give an error message and exit
if [ ! -e /dev/video0 ]; then
    echo "Error: No webcam found. Please connect a webcam and try again."
    exit 1
fi

# 2. Source ROS2
source /opt/ros/$ROS_DISTRO/setup.zsh

# 3. Compile the ROS2 package
cd $SCRIPTS_DIR
./compile_pkg.sh $ws_name $pkg_name

# 4. Source the local ROS2 workspace
source $ROS2_WS_DIR/install/local_setup.zsh

# 5. Add the local site-packages to PYTHONPATH, (from my .venv)
export PYTHONPATH="$(python3 -c 'import site; print(site.getsitepackages()[0])'):$PYTHONPATH"

# 6. Run the ROS2 node
ros2 run $pkg_name $node_name
