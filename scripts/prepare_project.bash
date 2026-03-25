#!/usr/bin/env bash
set -euo pipefail

# NOTE FOR AI AGENTS:
# This script creates an nbdev project that integrates with ROS2's system Python.
# Key insight: "uv init" creates an initial pyproject.toml, but "nbdev-new" replaces
# it with its own richer version. After nbdev-new runs, we must re-register the
# dependencies (pip, nbdev, ipykernel) into the NEW pyproject.toml so they're tracked.
# The packages are already installed in the venv; this just makes them visible to nbdev.

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

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
info()  { echo -e "${GREEN}[✔]${NC} $*"; }
warn()  { echo -e "${YELLOW}[!]${NC} $*"; }
error() { echo -e "${RED}[✘]${NC} $*"; exit 1; }

# Resolve project root from script location
SCRIPT_PATH="${BASH_SOURCE[0]:-$0}"
DIR_SCRIPT=$(cd "$(dirname "$SCRIPT_PATH")" && pwd -P)
PARENT_PATH=$(realpath "$DIR_SCRIPT/..")

info "Changing to the project root directory: $PARENT_PATH"
cd "$PARENT_PATH"

# Rename the template README so nbdev-new can create a fresh one.
# Skip if the destination already exists to avoid overwriting a previous rename.
if [ -f README_template_ros2dev.md ]; then
    warn "README_template_ros2dev.md already exists — skipping rename"
elif [ -f README.md ]; then
    mv README.md README_template_ros2dev.md
    info "Renamed README.md to README_template_ros2dev.md"
else
    warn "README.md not found — skipping rename"
fi

# Python version of the system, needed to create the right uv/nbdev project
PYTHON_BIN="/usr/bin/python3"
[ -x "$PYTHON_BIN" ] || error "python3 not found at $PYTHON_BIN"
info "Using system Python: $PYTHON_BIN ($(${PYTHON_BIN} --version 2>&1))"

# Start a uv project. Creates pyproject.toml
uv init --python "$PYTHON_BIN"
info "uv project initialised"

# Create venv with access to system site-packages (required for ROS2 python packages)
uv venv --python "$PYTHON_BIN" --system-site-packages
info "Virtual environment created with --system-site-packages"

# Install pip into the venv first so we can use it to snapshot system constraints
uv add pip
info "pip added to venv"

# Snapshot system package versions to use as install constraints.
# matplotlib-inline 0.2.1 (nbdev's preferred) is incompatible with the ROS2 system Matplotlib,
# so we pin it to 0.1.6 manually.
uv run pip list --format=freeze > system_constraints.txt
echo "matplotlib-inline==0.1.6" >> system_constraints.txt
info "system_constraints.txt generated"

# Add nbdev respecting system constraints
info "Adding nbdev to the project"
uv add nbdev --constraint system_constraints.txt

# Install Quarto before nbdev-new, which verifies quarto is available during setup
uv run nbdev-install-quarto
info "Quarto installed"

# Remove the uv-generated pyproject.toml so nbdev-new can create its own richer version
rm pyproject.toml

# Initialise the nbdev project (creates pyproject.toml, nbs/, etc.)
uv run nbdev-new
info "nbdev project initialised"

# Re-declare all dependencies in the nbdev-generated pyproject.toml
# The packages are already installed in the venv; this just registers them
uv add pip nbdev ipykernel --constraint system_constraints.txt
info "pip, nbdev and ipykernel registered in nbdev's pyproject.toml"

echo ""
echo "══════════════════════════════════"
info "Project setup complete!"
echo "══════════════════════════════════"