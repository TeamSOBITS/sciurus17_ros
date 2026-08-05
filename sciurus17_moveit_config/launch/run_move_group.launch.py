import os

from ament_index_python.packages import get_package_share_directory
from launch import LaunchDescription
from launch.actions import DeclareLaunchArgument
from launch.substitutions import LaunchConfiguration
from launch_ros.parameter_descriptions import ParameterValue
from moveit_configs_utils import MoveItConfigsBuilder
from moveit_configs_utils.launches import generate_move_group_launch
from moveit_configs_utils.launches import generate_moveit_rviz_launch
from sciurus17_description.robot_description_loader import RobotDescriptionLoader


def generate_launch_description():

    config_file_path = os.path.join(
        get_package_share_directory('sciurus17_control'), 'config', 'manipulator_config.yaml'
    )

    declare_port_name = DeclareLaunchArgument(
        'port_name',
        default_value='/dev/sciurus17spine',
        description='Set port name.'
    )

    declare_baudrate = DeclareLaunchArgument(
        'baudrate',
        default_value='3000000',
        description='Set baudrate.'
    )

    declare_timeout_seconds = DeclareLaunchArgument(
        'timeout_seconds',
        default_value='1.0',
        description='Set timeout seconds.'
    )

    declare_manipulator_config_file_path = DeclareLaunchArgument(
        'manipulator_config_file_path',
        default_value=config_file_path,
        description='Set manipulator config file path.'
    )

    declare_use_gazebo = DeclareLaunchArgument(
        'use_gazebo',
        default_value='false',
        description='Use gazebo or not.'
    )

    declare_use_gazebo_head_camera = DeclareLaunchArgument(
        'use_gazebo_head_camera',
        default_value='false',
        description='Use gazebo head camera or not.'
    )

    declare_use_gazebo_chest_camera = DeclareLaunchArgument(
        'use_gazebo_chest_camera',
        default_value='false',
        description='Use gazebo chest camera or not.'
    )

    declare_use_mock_components = DeclareLaunchArgument(
        'use_mock_components',
        default_value='false',
        description='Use mock_components or not.'
    )

    declare_gz_control_config_package = DeclareLaunchArgument(
        'gz_control_config_package',
        default_value='',
        description='Set gz control config package.'
    )

    declare_gz_control_config_file_path = DeclareLaunchArgument(
        'gz_control_config_file_path',
        default_value='',
        description='Set gz control config file path.'
    )

    declare_use_kachaka_base = DeclareLaunchArgument(
        'use_kachaka_base',
        default_value='false',
        description='Enable Kachaka mobile base.'
    )

    component_args = ['enable_head', 'enable_arm_right', 'enable_arm_left',
                      'enable_gripper_right', 'enable_gripper_left']

    declare_components = [
        DeclareLaunchArgument(name, default_value='true', description='Build this component.')
        for name in component_args
    ]

    description_loader = RobotDescriptionLoader()
    description_loader.port_name = LaunchConfiguration('port_name')
    description_loader.baudrate = LaunchConfiguration('baudrate')
    description_loader.timeout_seconds = LaunchConfiguration('timeout_seconds')
    description_loader.use_gazebo = LaunchConfiguration('use_gazebo')
    description_loader.use_gazebo_head_camera = LaunchConfiguration('use_gazebo_head_camera')
    description_loader.use_gazebo_chest_camera = LaunchConfiguration('use_gazebo_chest_camera')
    description_loader.use_mock_components = LaunchConfiguration('use_mock_components')
    description_loader.gz_control_config_package = LaunchConfiguration('gz_control_config_package')
    description_loader.gz_control_config_file_path = LaunchConfiguration(
        'gz_control_config_file_path'
    )
    description_loader.manipulator_config_file_path = LaunchConfiguration(
        'manipulator_config_file_path'
    )
    description_loader.use_kachaka_base = LaunchConfiguration('use_kachaka_base')
    for name in component_args:
        setattr(description_loader, name, LaunchConfiguration(name))
    loaded_description = description_loader.load()

    moveit_config = (
        MoveItConfigsBuilder('sciurus17')
        .robot_description_semantic(
            mappings={
                'use_kachaka_base': LaunchConfiguration('use_kachaka_base'),
                **{name: LaunchConfiguration(name) for name in component_args},
            }
        )
        .planning_scene_monitor(
            publish_robot_description=False,
            publish_robot_description_semantic=True,
        )
        .planning_pipelines(pipelines=['ompl'])
        .to_moveit_configs()
    )

    moveit_config.robot_description = {
        'robot_description': ParameterValue(loaded_description, value_type=str)
    }

    return LaunchDescription(
        [
            declare_port_name,
            declare_baudrate,
            declare_timeout_seconds,
            declare_manipulator_config_file_path,
            declare_use_gazebo,
            declare_use_gazebo_head_camera,
            declare_use_gazebo_chest_camera,
            declare_use_mock_components,
            declare_gz_control_config_package,
            declare_gz_control_config_file_path,
            declare_use_kachaka_base,
            *declare_components,
            generate_move_group_launch(moveit_config),
            generate_moveit_rviz_launch(moveit_config),
            # generate_static_virtual_joint_tfs_launch() is intentionally not used here.
            # It parses the SRDF while the launch file is being loaded, which is not
            # possible once the SRDF is generated from a xacro argument. It is also
            # unnecessary: in fixed-base mode the URDF declares world -> body_base_link
            # as a real joint that robot_state_publisher publishes, and with the Kachaka
            # base odom -> base_footprint comes from wheel_controller odometry.
        ]
    )
