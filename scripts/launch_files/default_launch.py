import os
from launch import LaunchDescription
from launch.actions import DeclareLaunchArgument, GroupAction
from launch.substitutions import LaunchConfiguration, PathJoinSubstitution
from launch_ros.actions import Node, PushRosNamespace
from launch_ros.substitutions import FindPackageShare

# Best Practices & Advice
# 1. Use Namespaces Judiciously
# Namespaces prevent naming collisions (e.g., if you have two robots, 
# you don't want both publishing to /cmd_vel).
#     Advice: Avoid hardcoding the namespace. Always use a LaunchArgument 
#     so the user can change it via the command line: 
#     $ ros2 launch my_pkg my_launch.py robot_ns:=r2d2.
# 
# 2. Declare All Parameters
# Never hardcode values inside your C++/Python nodes. Use a .yaml file and pass 
# it in the parameters=[...] list.
#     Advice: If you have a parameter that changes often, declare it as a 
#     LaunchArgument as well, so it can be overridden.
# 
# 3. Use PathJoinSubstitution
# Don't use + or string concatenation to build paths 
# (e.g., path = folder + "/file.xml").
#     Advice: PathJoinSubstitution handles different OS path separators 
#     (Linux vs. Windows) automatically.
# 
# 4. Remapping Topics
# If your node expects a topic like /scan but your sensor provides /lidar_data, 
# use the remappings list in the Node declaration. 
# It’s much cleaner than changing the source code.
# 
# How to test your launch file
# Once saved in your launch/ folder and installed via colcon, run it with:
# ros2 launch my_package_name example_launch.py robot_ns:=drone_01

def generate_launch_description():
    # 1. Define paths to other files (folders/configs)
    pkg_share = FindPackageShare('my_package_name')
    default_config_path = PathJoinSubstitution([pkg_share, 'config', 'params.yaml'])

    # 2. Declare Launch Arguments (the "Inputs" of your launch file)
    # Using arguments allows you to change behavior without editing code
    ns_arg = DeclareLaunchArgument(
        'robot_ns',
        default_value='robot_1',
        description='Namespace for the robot nodes'
    )

    use_sim_time_arg = DeclareLaunchArgument(
        'use_sim_time',
        default_value='false',
        description='Use simulation (Gazebo) clock if true'
    )

    # 3. Create Launch Configurations (to capture the argument values)
    robot_ns = LaunchConfiguration('robot_ns')
    use_sim_time = LaunchConfiguration('use_sim_time')

    # 4. Define your Nodes
    # Wrap nodes in a GroupAction to apply a Namespace or Remappings to all of them at once
    grouped_nodes = GroupAction(
        actions=[
            # This pushes the namespace to all nodes inside this group
            PushRosNamespace(robot_ns),
            
            Node(
                package='my_package_name',
                executable='my_node_exe',
                name='controller_node',
                output='screen',
                parameters=[
                    default_config_path,
                    {'use_sim_time': use_sim_time}
                ],
                remappings=[
                    ('/old_topic', 'new_topic'),
                ]
            ),
        ]
    )

    # 5. Return the LaunchDescription
    return LaunchDescription([
        ns_arg,
        use_sim_time_arg,
        grouped_nodes
    ])