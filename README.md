<a name="readme-top"></a>

[EN](README.md) | [JA](README_ja.md)

# sciurus17_ros

ROS 2 packages for driving the [Sciurus17](https://www.rt-net.jp/products/sciurus17), with optional
support for mounting it on a [Kachaka](https://kachaka.life/) mobile base to
turn it into a mobile manipulator.

![sciurus17_gazebo](https://rt-net.github.io/images/sciurus17/sciurus17_gazebo2.png "sciurus17_gazebo")

<!-- Table of Contents -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li><a href="#overview">Overview</a></li>
    <li>
      <a href="#setup">Setup</a>
      <ul>
        <li><a href="#requirements">Requirements</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li>
      <a href="#usage">Usage</a>
      <ul>
        <li><a href="#device-setup">Device Setup</a></li>
        <li><a href="#quick-start">Quick Start</a></li>
        <li><a href="#running-with-the-kachaka-base">Running with the Kachaka base</a></li>
        <li><a href="#visualization-in-rviz2">Visualization in RViz2</a></li>
        <li><a href="#running-the-simulator">Running the simulator</a></li>
      </ul>
    </li>
    <li><a href="#optional-components">Optional Components</a></li>
    <li>
      <a href="#base-configurations">Base Configurations</a>
      <ul>
        <li><a href="#frame-naming">Frame naming</a></li>
        <li><a href="#kinematic-structure">Kinematic structure</a></li>
      </ul>
    </li>
    <li><a href="#packages">Packages</a></li>
    <li><a href="#examples">Examples</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contributing">Contributing</a></li>
  </ol>
</details>

## Overview

This repository drives the Sciurus17 dual-arm robot under ROS 2. In addition to
the standard fixed-base configuration, it supports mounting the upper body on a
Kachaka mobile base, which is selected with the `use_kachaka_base` argument.

> [!CAUTION]
> If you are new to the robot, work alongside an experienced member when
> operating the real hardware.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Setup

### Requirements

| System | Version |
| --- | --- |
| Ubuntu | 24.04 (Noble Numbat) |
| ROS | Jazzy Jalisco |
| Python | 3.12 |

Hardware:

- Sciurus17 ([product page](https://www.rt-net.jp/products/sciurus17), [web shop](https://www.rt-shop.jp/index.php?main_page=product_info&products_id=3895))
- Kachaka mobile base (only for the mobile manipulator configuration)

> [!NOTE]
> For installing `Ubuntu` and `ROS`, see the [SOBITS Manual](https://github.com/TeamSOBITS/sobits_manual#%E9%96%8B%E7%99%BA%E7%92%B0%E5%A2%83%E3%81%AB%E3%81%A4%E3%81%84%E3%81%A6).

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Installation

1. Move into the `src` folder of your ROS workspace.
    ```sh
    cd ~/colcon_ws/src/
    ```

2. Clone this repository.
    ```sh
    git clone -b $ROS_DISTRO-devel https://github.com/TeamSOBITS/sciurus17_ros.git
    ```

3. Move into the repository.
    ```sh
    cd sciurus17_ros/
    ```

4. Install the dependencies.
    ```sh
    bash install.sh
    ```

5. Build.
    ```sh
    cd ~/colcon_ws/
    source /opt/ros/$ROS_DISTRO/setup.bash
    colcon build --symlink-install
    source ~/colcon_ws/install/setup.bash
    ```

> [!NOTE]
> `install.sh` clones `sciurus17_description`, `sciurus17_kachaka_description`,
> `kachaka-api` and `realsense_ros` next to this repository.
> `sciurus17_kachaka_description` is a private repository, so you need access to
> the TeamSOBITS organization to clone it. It is only required for the Kachaka
> configuration.

> [!IMPORTANT]
> `realsense_ros` is built from source rather than installed from apt, because
> its own `install.sh` also builds `librealsense2` and installs the udev rules
> that the head and hand cameras need in order to be detected. This step compiles
> `librealsense2`, so the first run of `install.sh` takes a while.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Usage

### Device Setup

Fix the name of the USB serial device that `sciurus17_control` uses to talk to
the hardware:

```sh
ros2 run sciurus17_tools create_udev_rules
```

Reboot and reconnect the Sciurus17; `/dev/sciurus17spine` will then be created.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Quick Start

The following opens and closes the gripper.

```sh
# Connect the Sciurus17 to the PC, then
source ~/colcon_ws/install/setup.bash
ros2 launch sciurus17_examples demo.launch.py

# Terminal 2
source ~/colcon_ws/install/setup.bash
ros2 launch sciurus17_examples example.launch.py example:='gripper_control'

# Press [Ctrl-c] to terminate.
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Running with the Kachaka base

1. [Local environment] Start the ROS bridge container for the Kachaka.
    ```sh
    kachaka <Kachaka IP address> sciurus17 no yes
    ```

> [!WARNING]
> The Kachaka IP address may change. Check it by asking the robot
> ("ねぇカチャカ、IPアドレスを教えて") or through the Kachaka app.

2. Launch the robot with the mobile base enabled.
    ```sh
    ros2 launch sciurus17_examples demo.launch.py use_kachaka_base:=true
    ```

> [!IMPORTANT]
> Pass `use_kachaka_base` to the top-level launch file. It is forwarded from
> there to the robot description, MoveIt and the controllers, so that all three
> describe the same robot.

If the robot does not come up, check that:

- the emergency stop button is not engaged
- the battery is sufficiently charged
- the USB hub is connected to the PC
- the Kachaka IP address is correct
- `ROS_DOMAIN_ID` matches between the environments

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Visualization in RViz2

```sh
# Fixed base
ros2 launch sciurus17_description display.launch.py

# With the Kachaka base
ros2 launch sciurus17_description display.launch.py use_kachaka_base:=true
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Running the simulator

```sh
# Fixed base
ros2 launch sciurus17_gazebo sciurus17_gazebo.launch.py

# With the Kachaka base
ros2 launch sciurus17_gazebo sciurus17_gazebo.launch.py use_kachaka_base:=true
```

In the fixed-base configuration the robot is spawned on the table. With the
Kachaka base it is spawned on the floor beside it, and `wheel_controller`
(a `diff_drive_controller`) accepts velocity commands.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Optional Components

The head, each arm and each gripper can be left out of the robot, so the same
packages can drive a partially assembled Sciurus17. Every component defaults to
`true`.

| Argument | Component |
| --- | --- |
| `enable_head` | Neck joints and the head camera frames |
| `enable_arm_right` | Right arm (and its gripper) |
| `enable_arm_left` | Left arm (and its gripper) |
| `enable_gripper_right` | Right gripper only, keeping the arm |
| `enable_gripper_left` | Left gripper only, keeping the arm |

```sh
# A left arm and gripper only, no head and no right arm
ros2 launch sciurus17_examples demo.launch.py \
    enable_head:=false enable_arm_right:=false
```

Disabling a component removes its links and joints from the URDF, its joints
from `ros2_control`, its planning groups from the SRDF, and its controller from
the launch files, so nothing is left referring to hardware that is not there.

> [!IMPORTANT]
> Pass these to the top-level launch file. They are forwarded to the robot
> description, MoveIt and the controllers, which must all agree on which
> components exist.

> [!NOTE]
> A gripper needs its arm, since it mounts on the arm's wrist. Setting
> `enable_arm_right:=false` therefore also removes the right gripper, and
> requesting a gripper whose arm is disabled has no effect.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Base Configurations

The robot description supports two configurations, selected with
`use_kachaka_base`:

| Value | Configuration |
| --- | --- |
| `false` (default) | Fixed base. The upper body is bolted to a static `world` frame. |
| `true` | Kachaka base. The upper body is carried by a Kachaka mobile platform. |

The default configuration has no dependency on the Kachaka packages.

### Frame naming

The manipulator base frame is `body_base_link`.

This matters with the Kachaka base, because the Kachaka platform brings its own
link called `base_link`. The two are different frames:

| Frame | Meaning |
| --- | --- |
| `body_base_link` | Root of the Sciurus17 upper body (arms, neck, cameras) |
| `base_link` | Kachaka mobile platform body (only with the Kachaka base) |

> [!IMPORTANT]
> Express manipulator goal poses in `body_base_link`. It exists in both
> configurations, whereas `world` exists only without the Kachaka base and
> `base_link` only with it.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Kinematic structure

**Fixed base (`use_kachaka_base:=false`)**

```
world
  └─ body_base_link
      └─ body_link
          ├─ neck_yaw_link
          ├─ l_link1 (left arm)
          └─ r_link1 (right arm)
```

`world -> body_base_link` is a fixed joint declared in the URDF, so
`robot_state_publisher` publishes it.

**Kachaka base (`use_kachaka_base:=true`)**

```
odom
  └─ base_footprint
      └─ base_link (Kachaka platform)
          ├─ base_l_drive_wheel_link
          ├─ base_r_drive_wheel_link
          └─ kachaka_base_link
              └─ sciurus17_vehicle_body_lower_front_link
                  └─ sciurus17_vehicle_body_upper_link
                      └─ body_base_link
                          └─ body_link
                              ├─ neck_yaw_link
                              ├─ l_link1 (left arm)
                              └─ r_link1 (right arm)
```

There is no `world` link in this mode. `odom -> base_footprint` is published by
`wheel_controller` from wheel odometry, and the SRDF anchors the robot with a
planar virtual joint accordingly.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Packages

- sciurus17_control
  - [README](./sciurus17_control/README.md)
  - Controls the Sciurus17. Includes `wheel_controller` for the Kachaka base.
- sciurus17_examples
  - [README](./sciurus17_examples/README.md)
  - C++ sample code.
- sciurus17_examples_py
  - [README](./sciurus17_examples_py/README.md)
  - Python sample code.
- sciurus17_gazebo
  - Gazebo simulation package.
- sciurus17_moveit_config
  - `MoveIt 2` configuration. The SRDF is generated from
    `config/sciurus17.srdf.xacro` so it can follow `use_kachaka_base`.
- sciurus17_tools
  - Optional tools, including the udev rule generator.
- sciurus17_vision
  - Camera launch files and image recognition nodes. The chest camera
    calibration is [chest_camera_info.yaml](./sciurus17_vision/config/chest_camera_info.yaml).
- sciurus17_description (external package)
  - [README](https://github.com/TeamSOBITS/sciurus17_description/blob/jazzy-devel/README.md)
  - Defines the Sciurus17 model data (xacro).
- sciurus17_kachaka_description (external package, private)
  - URDF macros and meshes for the Kachaka mount and vehicle body.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Examples

Sample programs are provided in both C++ and Python:

- C++ — [sciurus17_examples](./sciurus17_examples/README.md)
- Python — [sciurus17_examples_py](./sciurus17_examples_py/README.md)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## License

(C) 2018 RT Corporation \<support@rt-net.jp\>

Files with a license explicitly stated follow that license. Otherwise, this
software is released under the Apache License, Version 2.0. The full text is
available in [LICENSE](./LICENSE) or at
[https://www.apache.org/licenses/LICENSE-2.0](https://www.apache.org/licenses/LICENSE-2.0).

[sciurus17_description](https://github.com/TeamSOBITS/sciurus17_description), on
which this package depends, is covered by RT Corporation's non-commercial
license. See
[sciurus17_description/LICENSE](https://github.com/TeamSOBITS/sciurus17_description/blob/jazzy-devel/LICENSE)
for details.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Contributing

- This software is open source, but development is not open.
- It is provided "AS IS" as open source software.
- No free support is available.
- Requests for bug fixes and typo corrections are always welcome. For other
  feature requests, internal guidelines take precedence.

See the [contribution guidelines](https://github.com/rt-net/.github/blob/master/CONTRIBUTING.md#contribution-guide-en).

<p align="right">(<a href="#readme-top">back to top</a>)</p>
