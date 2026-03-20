# Copilot Instructions

## Project Overview

ROS2 development template combining **uv** (package manager), **nbdev** (notebook-driven development), and **ROS2**. Notebooks in `nbs/` are the source of truth — they export to Python modules, tests, and docs via nbdev.

The virtual environment uses `--system-site-packages` so Python can access ROS2 system packages alongside uv-managed dependencies.

## Architecture

### Workspace & Package Layout

ROS2 workspaces live at the repo root (e.g., `new_ros2_ws/`). Node source files go in:

```
<workspace>/src/<package>/<package>/   ← Python node files here
<workspace>/src/<package>/launch/      ← launch files
<workspace>/src/<package>/config/      ← parameter YAML files
```

### Auto-Generated Entry Points

`compile_pkg.sh` generates `setup.py` from the `universal_setup.py` template. It scans the package directory for Python files and registers each as a `console_scripts` entry point automatically. **Do not hand-edit `setup.py`** — it gets overwritten on every build.

Each node file must define a `main()` function:

```python
def main(args=None):
    rclpy.init(args=args)
    node = MyNode()
    rclpy.spin(node)
    node.destroy_node()
    rclpy.shutdown()
```

### Template System

`universal_setup.py` uses `{{PKG_NAME}}`, `{{MAINTAINER}}`, `{{EMAIL}}` placeholders. `compile_pkg.sh` substitutes these from arguments and `git config`. Custom asset folders (launch, config, etc.) are auto-collected into `share/<package>/` via `generate_data_files()`.

## Build & Run Commands

```sh
# Install system dependencies (curl, git, uv, python3)
bash scripts/basic_install.sh

# Scaffold uv + nbdev project (venv, nbdev, quarto)
bash scripts/prepare_project.bash

# Create a ROS2 workspace
zsh scripts/generate_ros2_ws.zsh [workspace_name]

# Create a ROS2 package (with OpenCV deps)
zsh scripts/mk_ros2pkg_opencv.zsh [workspace_name] [package_name]

# Create a ROS2 package (custom deps from .txt file)
zsh scripts/mk_ros2_pkg.sh [workspace_name] [package_name] [deps_file]

# Compile a package (auto-generates setup.py + colcon build)
bash scripts/compile_pkg.sh [workspace_name] [package_name]

# Source workspace and run a single node
source [workspace_name]/install/setup.bash
ros2 run [package_name] [node_name]
```

### Testing

```sh
# Run all notebook tests
uv run nbdev-test

# Run a single notebook's tests
uv run nbdev-test --path nbs/00_core.ipynb

# Export notebooks to Python modules
uv run nbdev-export

# Quick-test a ROS2 node without compiling
python3 <workspace>/src/<package>/<package>/my_node.py
```

## Key Conventions

- **Default ROS2 distro is Jazzy** (configured in `.vscode/settings.json`). Ask the user if targeting a different distro.
- **Shell matters:** `generate_ros2_ws.zsh`, `mk_ros2pkg_opencv.zsh`, and `mk_ros2_pkg.sh` require **zsh** (the `.sh` extension on `mk_ros2_pkg.sh` is misleading — its shebang is `#!/bin/zsh`).
- **Dependencies:** Use `uv add <package>` for Python packages. ROS2 package dependencies are declared in `package.xml` and dependency `.txt` files under `scripts/pkg_dependencies/`.
- **Constraint pinning:** `matplotlib-inline==0.1.6` is pinned in `system_constraints.txt` for ROS2 compatibility (set up by `prepare_project.bash`).
- Prefer small, safe changes. Ask before running commands that modify system state or install packages.
