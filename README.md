# 🤖 template_ros2_dev

**ROS2 development with notebook-driven code and blazing-fast package management.**

This template combines [ROS2](https://docs.ros.org/) with [uv](https://docs.astral.sh/uv/) and [nbdev](https://nbdev.fast.ai/) so you can write, test, document, and deploy ROS2 nodes without leaving your notebooks.

> **Prerequisite:** ROS2 must be installed on your system. `uv` and `nbdev` are installed by this template.

---

## ⚡ Quick start

```sh
# 1. Use this template on GitHub, then clone your repo
git clone https://github.com/<you>/<your-project>.git && cd <your-project>

# 2. Install system dependencies (curl, git, uv, python3)
bash scripts/basic_install.sh

# 3. Scaffold the uv + nbdev project (venv, nbdev, quarto)
bash scripts/prepare_project.bash
```

---

## 🏗️ Create a ROS2 workspace and package

```sh
# Create a ROS2 workspace (default name: new_ros2_ws)
zsh scripts/generate_ros2_ws.zsh [workspace_name]

# Create a ROS2 package with OpenCV dependencies (camera example)
zsh scripts/mk_ros2pkg_opencv.zsh [workspace_name] [package_name]
```

`mk_ros2pkg_opencv.zsh` creates the workspace if it doesn't exist, then scaffolds the package with:
- **`launch/`** — a ready-to-edit launch file template
- **`config/`** — a parameter YAML template for your nodes

Use `mk_ros2_pkg.sh` to create a package with custom dependencies from a `.txt` file.

---

## ✍️ Write your nodes

Place your Python node files in:

```
[workspace_name]/src/[package_name]/[package_name]/
```

Name each file after the ROS2 entry point you want (e.g. `camera_publisher.py`). Each file should define a node class and a `main()` function:

```python
def main(args=None):
    rclpy.init(args=args)
    node = MyNode()
    rclpy.spin(node)
    node.destroy_node()
    rclpy.shutdown()
```

> **Quick test without compiling:** source your ROS2 installation and run `python3 my_node.py` directly.

---

## 🔨 Compile and run

```sh
# Auto-generates entry points in setup.py and runs colcon build
bash scripts/compile_pkg.sh [workspace_name] [package_name]

# Source the workspace
source [workspace_name]/install/setup.bash

# Run a node
ros2 run [package_name] [node_name]

# Or launch multiple nodes at once
ros2 launch [package_name] default_launch.py
```

`compile_pkg.sh` scans your package folder, writes all Python files as entry points in `setup.py` automatically — no manual editing needed.

---

## 📁 Project structure after setup

```
your-project/
├── nbs/                        # Jupyter notebooks (source of truth)
├── your_project/               # Auto-exported Python package (nbdev)
├── pyproject.toml              # Dependencies — add with `uv add <pkg>`
├── uv.lock                     # Locked dependencies
├── .venv/                      # Virtual environment (system-site-packages for ROS2)
├── [workspace_name]/           # ROS2 workspace
│   └── src/[package_name]/
│       ├── [package_name]/     # Your node .py files go here
│       ├── launch/             # Launch file templates
│       └── config/             # Parameter YAML templates
└── scripts/
    ├── basic_install.sh        # Installs curl, git, uv, python3
    ├── prepare_project.bash    # Sets up uv + nbdev project
    ├── generate_ros2_ws.zsh    # Creates a ROS2 workspace
    ├── mk_ros2_pkg.sh          # Creates a ROS2 package (custom deps)
    ├── mk_ros2pkg_opencv.zsh   # Creates a ROS2 package (OpenCV example)
    └── compile_pkg.sh          # Auto-generates setup.py + colcon build
```

---

## 🛠️ Daily workflow

| Task | Command |
|------|---------|
| Add a Python package | `uv add <package>` |
| Export notebooks → modules | `uv run nbdev-export` |
| Run notebook tests | `uv run nbdev-test` |
| Build documentation | `uv run nbdev-docs` |
| Compile ROS2 package | `bash scripts/compile_pkg.sh <ws> <pkg>` |
| Run a ROS2 node | `ros2 run <pkg> <node>` |

---

## 💡 Why uv + nbdev with ROS2?

- **uv** manages all non-ROS Python packages at native speed, with a venv that can also see ROS2 system packages (`--system-site-packages`)
- **nbdev** lets you prototype nodes in notebooks, then export clean Python modules into your ROS2 package
- **Quarto** auto-generates documentation from your notebooks
