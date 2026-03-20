from importlib.resources import path
import os
import glob
from pathlib import Path

""" 
This script automatically updates the setup.py file by detecting all Python modules
in the package and adding them to the console_scripts entry points.
All the Python files in the package (except __init__.py) will be added as entry points.
The Python files should have a main() function defined, which will be the entry point when the node is run.
Name your Python files according to the name you want to use to run this kind of node.
    e.g.: camera_publisher.py will create a an entry point to run:
          $ ros2 run <package_name> camera_publisher
Differentiate between naming conventions.
    - name of the python file (without .py) (Here we use the same as the entry point name)
    - name of the node (defined in the constructor of the Node class. It can be remapped at runtime)
    - name of the entry point (defined in the setup.py file. It is the name we use to run the node with ros2 run)
Remapping topics and nodes at runtime:
    - You can remap topics and nodes at runtime using ROS2 command line arguments with -ros-args -r .
    - For example, to remap a topic:
    $ ros2 run <package_name> <node_entry_point_name> --ros-args -r __node:=<node_name> <orig_topic>:=<new_topic>
"""

def generate_setup():
    # 1. Identify the package name (the subdirectory containing __init__.py)
    pkg_name = [d for d in os.listdir('.') if os.path.isdir(d) and os.path.exists(os.path.join(d, '__init__.py'))][0]
    
    # 2. Search for .py files (excluding __init__.py and any file starting with underscore)
    pkg_path = Path(pkg_name)
    py_files = [p.stem for p in pkg_path.glob("*.py") if not p.name.startswith("_")]
    
    # 3. Generate the entry_points lines
    entry_points_lines = [f"            '{name} = {pkg_name}.{name}:main'," for name in py_files]

    # 4. Read the original setup.py to keep metadata (maintainer, description, etc.)
    with open('setup.py', 'r') as f:
        content = f.read()

    # 5. Cut and Reassemble
    # Find where the console_scripts list starts and ends
    start_marker = "'console_scripts': ["
    end_marker = "],"
    
    header = content.split(start_marker)[0] + start_marker
    # Find the end of the list after the start_marker
    footer = "]," + content.split(start_marker)[1].split(end_marker, 1)[1]

    # 6. Write the new file
    with open('setup.py', 'w') as f:
        f.write(header + "\n")
        f.write("\n".join(entry_points_lines) + "\n")
        f.write("        " + footer)

    print(f"✅ Setup.py updated. Nodes detected: {', '.join(py_files)}")

if __name__ == "__main__":
    generate_setup()