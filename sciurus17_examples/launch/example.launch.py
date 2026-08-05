# Copyright 2023 RT Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

from launch import LaunchDescription
from launch.actions import DeclareLaunchArgument
from launch.substitutions import LaunchConfiguration
from launch_ros.actions import Node
from launch_ros.actions import SetParameter
from launch_ros.parameter_descriptions import ParameterValue
from moveit_configs_utils import MoveItConfigsBuilder
from sciurus17_description.robot_description_loader import RobotDescriptionLoader


def generate_launch_description():
    declare_example_name = DeclareLaunchArgument(
        'example',
        default_value='gripper_control',
        description=(
            'Set an example executable name: '
            '[gripper_control, pose_groupstate, joint_values, neck_control, waist_control,'
            'pick_and_place_right_arm_waist, pick_and_place_left_arm, head_camera_tracking, '
            'chest_camera_tracking]'
        ),
    )
    declare_use_sim_time = DeclareLaunchArgument(
        'use_sim_time',
        default_value='false',
        description=('Set true when using the gazebo simulator.'),
    )

    declare_use_kachaka_base = DeclareLaunchArgument(
        'use_kachaka_base', default_value='false', description='Enable Kachaka mobile base.'
    )

    description_loader = RobotDescriptionLoader()
    description_loader.use_kachaka_base = LaunchConfiguration('use_kachaka_base')

    moveit_config = (
        MoveItConfigsBuilder('sciurus17')
        .robot_description_semantic(
            mappings={'use_kachaka_base': LaunchConfiguration('use_kachaka_base')}
        )
        .to_moveit_configs()
    )
    moveit_config.robot_description = {
        'robot_description': ParameterValue(description_loader.load(), value_type=str),
    }

    example_node = Node(
        name=[LaunchConfiguration('example'), '_node'],
        package='sciurus17_examples',
        executable=LaunchConfiguration('example'),
        output='screen',
        parameters=[moveit_config.to_dict()],
    )

    return LaunchDescription(
        [
            declare_example_name,
            declare_use_sim_time,
            declare_use_kachaka_base,
            SetParameter(
                name='use_sim_time', value=LaunchConfiguration('use_sim_time')
            ),
            example_node,
        ]
    )
