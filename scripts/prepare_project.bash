#! /bin/bash

# Changes with respect to the original template:
# - ROS2 is installed in the system, so we need to use the system python packages 
#   in the uv virtual environment, which is needed to use ROS2 python packages.
# - uv should not use the latest python version, so we first check the python version
#   and init the uv project with that version. 
# - uv venv --system-site-packages is first run to allow .venv to see the system python packages
# - When installing nbdev, it will install matplotlib-inline 0.2.1 (its latest version),
#   however, the latest version of matplotlib-inline is not compatible with the system Matplotlib that 
#   is required by ROS2.
# - We create a constraints.txt file with the compatible version of matplotlib-inline, 
#   which is the only package that is incompatible with the system python packages.
# - We use the --constraint option of uv add to install nbdev with the compatible versions
# - It seems that there is no automatic way to know that matplotlib-inline 0.2.1
#   is incompatible with the system Matplotlib, so we need to manually add it to the constraints.txt file.

# It looks for the parent directory of this script, which should be the root of the project 
SCRIPT_PATH="${BASH_SOURCE[0]:-$0}"
DIR_SCRIPT=$(cd "$(dirname "$SCRIPT_PATH")" && pwd -P)
PARENT_PATH="$DIR_SCRIPT/.."

# Python version of the system, which is needed to create the right nbdev project.
PYTHON_VERSION=$(python3 --version | awk '{print $2}' | cut -d. -f1,2)

echo "Changing to the project root directory: $PARENT_PATH"
cd "$PARENT_PATH"

# Remove the template README.md file, since we will create our own.
rm README.md

# Start a uv project where I can easily install dependencies. It creates a pyproject.toml file
echo "Starting a uv project with system python version: $PYTHON_VERSION"
uv init -p $PYTHON_VERSION

# Allow to use the system python packages in the uv virtual environment, which is needed to use ROS2 python packages.
echo "Creating a uv virtual environment with system site packages"
uv venv --system-site-packages

# This checks the constraints of the system python packages, 
# which is needed to avoid installing incompatible versions of packages 
# when we add nbdev and its dependencies.
pip list --format=freeze > system_constraints.txt
echo "matplotlib-inline==0.1.6" >> system_constraints.txt

# Add a local nbdev to the project.
echo "Adding nbdev to the project with uv"
uv add nbdev --constraint system_constraints.txt

# Remove uv pyproject.toml, since we will use the one from nbdev, 
# which is more complete and has the right dependencies.
rm pyproject.toml

# Create the nbdev project (Adds its own pyproject.toml which can be updated easily with uv add)
# uv run nbdev-new to use the nbdev locally installed by uv in .venv
uv run nbdev-new

# Add packages to run the notebooks in ipykernels
echo "Adding pip and ipykernel"
uv add pip ipykernel --constraint system_constraints.txt
