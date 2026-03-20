from setuptools import find_packages, setup
import os
from glob import glob
from typing import Sequence
from pathlib import Path

package_name = '{{PKG_NAME}}'

# Ensure compatibility with setuptools' data_files
# Handles empty directories and non-standard paths gracefully

def generate_data_files() -> list[tuple[str, Sequence[str]]] | None:
    data_files: list[tuple[str, Sequence[str]]] = [
        ('share/ament_index/resource_index/packages', ['resource/' + package_name]),
        ('share/' + package_name, ['package.xml']),
    ]

    # Folders to scan for assets
    ignore_folders = [package_name, 'resource', 'test', 'build', 'install', 'log', '__pycache__']

    for entry in os.listdir('.'):  # Iterate through top-level directories
        if os.path.isdir(entry) and entry not in ignore_folders and not entry.startswith('.'):
            for root, dirs, files in os.walk(entry):
                if files:  # Only include directories with files
                    # Maps local folder structure to the share/ install directory
                    install_path = os.path.join('share', package_name, root)
                    file_list = [os.path.join(root, f) for f in files if os.path.isfile(os.path.join(root, f))]
                    data_files.append((install_path, file_list))
    return data_files if data_files else None

def generate_entry_points() -> list[str]:
    # Identify the package name (the subdirectory containing __init__.py)
    pkg_name = [d for d in os.listdir('.') if os.path.isdir(d) and os.path.exists(os.path.join(d, '__init__.py'))][0]

    # Search for .py files (excluding __init__.py and any file starting with underscore)
    pkg_path = Path(pkg_name)
    py_files = [p.stem for p in pkg_path.glob("*.py") if not p.name.startswith("_")]

    # Generate the entry_points lines
    entry_points = [f"{name} = {pkg_name}.{name}:main" for name in py_files]
    return entry_points

setup(
    name=package_name,
    version='0.0.0',
    packages=find_packages(exclude=['test']),
    data_files=generate_data_files(),
    install_requires=['setuptools'],
    zip_safe=True,
    maintainer='{{MAINTAINER}}',
    maintainer_email='{{EMAIL}}',
    description='Auto-generated ROS 2 package',
    license='Apache-2.0',
    tests_require=['pytest'],
    entry_points={
        'console_scripts': generate_entry_points(),
    },
)