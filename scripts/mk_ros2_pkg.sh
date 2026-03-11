#!/bin/zsh

# ------ Inputs and Paths -------------------------------------------
# Input parameters with defaults
ws_name=${1:-new_ros2_ws}
pkg_name=${2:-pkg_ros2_opencv}
deps_file=${3:-camera_opencv.txt}
echo "Build a ROS2 workspace $ws_name with a package $pkg_name and dependencies from $deps_file"

LICENSE="Apache-2.0"


# Relevant paths
SCRIPT_PATH="${BASH_SOURCE[0]:-$0}"
DIR_SCRIPT=$(cd "$(dirname "$SCRIPT_PATH")" && pwd -P)
PARENT_PATH=$(cd "$DIR_SCRIPT/.." && pwd -P) # Ensure absolute path
DEPS_PATH="$DIR_SCRIPT/pkg_dependencies/$deps_file" # Adjusted to use DIR_SCRIPT directly

# Navigate to the parent directory of the script
cd "$PARENT_PATH"

# Check if the dependencies file exists
if [[ ! -f "$DEPS_PATH" ]]; then
    echo "Dependency file not found: $DEPS_PATH"
    exit 1
fi


# ------ ROS2 Workspace Creation -------------------------------------------
# Generate the ROS2 workspace using the provided script
zsh "$PARENT_PATH/scripts/generate_ros2_ws.zsh" $ws_name

# ------ ROS2 Package Creation -------------------------------------------
# Read dependencies ignoring comments and empty lines
dependency_list=()
while IFS= read -r line; do
    [[ -z "$line" || "$line" == \#* ]] && continue
    dependency_list+=("$line")
done < "$DEPS_PATH"

# GO to the src folder of the workspace
cd "$ws_name/src"

# ROS2 Package Creation
if [[ ! -d "$pkg_name" ]]; then
    echo "Package $pkg_name does not exist. Creating..."

    ros2 pkg create --build-type ament_python "$pkg_name" \
        --license "$LICENSE" \
        --dependencies "${dependency_list[@]}"

    [[ $? -eq 0 ]] && echo "Package $pkg_name created successfully."
else
    echo "Package $pkg_name already exists."
fi

# ------ Launch Folder and Files -------------------------------------------
# Launch folder creation
if [[ ! -d "$pkg_name/launch" ]]; then
    mkdir "$pkg_name/launch"
    echo "Launch folder created in $pkg_name."
else
    echo "Launch folder already exists in $pkg_name."
fi

# After creating the launch folder, copy the launch template to the package
cp "$DIR_SCRIPT/launch_files/"*launch.(py|xml|yaml) "$pkg_name/launch/"
echo "Launch script copied to $pkg_name/launch."


# ------ Config Folder and Files -------------------------------------------
# Ensure the config folder exists before copying the default config file
if [[ ! -d "$pkg_name/config" ]]; then
    mkdir "$pkg_name/config"
    echo "Config folder created in $pkg_name."
fi

# Copy the default config file to the package
cp "$DIR_SCRIPT/config_files/default_config.yaml" "$pkg_name/config/"
echo "Default config file copied to $pkg_name/config."