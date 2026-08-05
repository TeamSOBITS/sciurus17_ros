<a name="readme-top"></a>

[EN](README.md) | [JA](README_ja.md)

# sciurus17_ros

ROS 2で[Sciurus17](https://www.rt-net.jp/products/sciurus17)を動作させるパッケージです。
オプションで[カチャカ](https://kachaka.life/)の移動機構に搭載し、モバイルマニピュレータとして
動作させることもできます。

![sciurus17_gazebo](https://rt-net.github.io/images/sciurus17/sciurus17_gazebo2.png "sciurus17_gazebo")

<!-- 目次 -->
<details>
  <summary>目次</summary>
  <ol>
    <li><a href="#概要">概要</a></li>
    <li>
      <a href="#セットアップ">セットアップ</a>
      <ul>
        <li><a href="#環境条件">環境条件</a></li>
        <li><a href="#インストール方法">インストール方法</a></li>
      </ul>
    </li>
    <li>
      <a href="#実行操作方法">実行・操作方法</a>
      <ul>
        <li><a href="#デバイスの設定">デバイスの設定</a></li>
        <li><a href="#クイックスタート">クイックスタート</a></li>
        <li><a href="#カチャカベースでの実行">カチャカベースでの実行</a></li>
        <li><a href="#rviz2上の可視化">RViz2上の可視化</a></li>
        <li><a href="#シミュレータの実行方法">シミュレータの実行方法</a></li>
      </ul>
    </li>
    <li><a href="#オプション構成要素">オプション構成要素</a></li>
    <li>
      <a href="#ベース構成">ベース構成</a>
      <ul>
        <li><a href="#座標系の名前">座標系の名前</a></li>
        <li><a href="#リンク構造">リンク構造</a></li>
      </ul>
    </li>
    <li><a href="#パッケージ">パッケージ</a></li>
    <li><a href="#サンプルプログラム">サンプルプログラム</a></li>
    <li><a href="#ライセンス">ライセンス</a></li>
    <li><a href="#コントリビューション">コントリビューション</a></li>
  </ol>
</details>

## 概要

ROS 2で双腕ロボットSciurus17を動作させるためのパッケージです。
標準の固定ベース構成に加えて、上半身をカチャカの移動機構に搭載する構成にも対応しており、
`use_kachaka_base`引数で切り替えます。

> [!CAUTION]
> 初心者の場合、実機のロボットを扱う際は、先輩方に付き添ってもらいながら動かしましょう。

<p align="right">(<a href="#readme-top">上に戻る</a>)</p>

## セットアップ

### 環境条件

| System | Version |
| --- | --- |
| Ubuntu | 24.04 (Noble Numbat) |
| ROS | Jazzy Jalisco |
| Python | 3.12 |

ハードウェア：

- Sciurus17（[製品ページ](https://www.rt-net.jp/products/sciurus17)、[ウェブショップ](https://www.rt-shop.jp/index.php?main_page=product_info&products_id=3895)）
- カチャカ移動機構（モバイルマニピュレータ構成の場合のみ）

> [!NOTE]
> `Ubuntu`や`ROS`のインストール方法に関しては、[SOBITS Manual](https://github.com/TeamSOBITS/sobits_manual#%E9%96%8B%E7%99%BA%E7%92%B0%E5%A2%83%E3%81%AB%E3%81%A4%E3%81%84%E3%81%A6)を参照してください。

<p align="right">(<a href="#readme-top">上に戻る</a>)</p>

### インストール方法

1. ROSのワークスペース`src`フォルダに移動します。
    ```sh
    cd ~/colcon_ws/src/
    ```

2. 本レポジトリをcloneします。
    ```sh
    git clone -b $ROS_DISTRO-devel https://github.com/TeamSOBITS/sciurus17_ros.git
    ```

3. レポジトリの中へ移動します。
    ```sh
    cd sciurus17_ros/
    ```

4. 依存パッケージをインストールします。
    ```sh
    bash install.sh
    ```

5. ビルドします。
    ```sh
    cd ~/colcon_ws/
    source /opt/ros/$ROS_DISTRO/setup.bash
    colcon build --symlink-install
    source ~/colcon_ws/install/setup.bash
    ```

> [!NOTE]
> `install.sh`は`sciurus17_description`、`sciurus17_kachaka_description`、`kachaka-api`、
> `realsense_ros`を本レポジトリの隣にcloneします。`sciurus17_kachaka_description`は
> プライベートレポジトリのため、cloneにはTeamSOBITS organizationへのアクセス権が必要です。
> カチャカ構成を使用しない場合は不要です。

> [!IMPORTANT]
> `realsense_ros`はaptではなくソースからビルドします。`realsense_ros`の`install.sh`が
> `librealsense2`のビルドと、ヘッドカメラ・ハンドカメラの認識に必要なudevルールの設定も
> 行うためです。`librealsense2`のコンパイルを伴うため、`install.sh`の初回実行には時間がかかります。

<p align="right">(<a href="#readme-top">上に戻る</a>)</p>

## 実行・操作方法

### デバイスの設定

`sciurus17_control`が実機と通信するために用いるUSBシリアル変換デバイス名を固定します。

```sh
ros2 run sciurus17_tools create_udev_rules
```

実行後に再起動しSciurus17を接続すると`/dev/sciurus17spine`が作成されるようになります。

<p align="right">(<a href="#readme-top">上に戻る</a>)</p>

### クイックスタート

以下のコマンドを実行すると、Sciurus17がグリッパ開閉動作をします。

```sh
# Sciurus17をPCに接続してから
source ~/colcon_ws/install/setup.bash
ros2 launch sciurus17_examples demo.launch.py

# Terminal 2
source ~/colcon_ws/install/setup.bash
ros2 launch sciurus17_examples example.launch.py example:='gripper_control'

# Press [Ctrl-c] to terminate.
```

<p align="right">(<a href="#readme-top">上に戻る</a>)</p>

### カチャカベースでの実行

1. [ローカル環境] カチャカとのROS BridgeのDockerコンテナを立ち上げます。
    ```sh
    kachaka <カチャカのIPアドレス> sciurus17 no yes
    ```

> [!WARNING]
> カチャカのIPアドレスは変わる可能性があります。ロボットに「ねぇカチャカ、IPアドレスを教えて」と
> 話しかけるか、カチャカアプリから確認してください。

2. 移動機構を有効にしてロボットを起動します。
    ```sh
    ros2 launch sciurus17_examples demo.launch.py use_kachaka_base:=true
    ```

> [!IMPORTANT]
> `use_kachaka_base`は最上位のlaunchファイルに渡してください。そこからロボットの記述、MoveIt、
> コントローラへ転送され、3者が同じロボットを参照するようになります。

ロボットが立ち上がらない場合は、次を確認してください。

- 緊急停止ボタンが押下されていないか
- バッテリが十分に充電されているか
- USB hubがパソコンと接続されているか
- カチャカのIPアドレスが正しいか
- `ROS_DOMAIN_ID`が一致しているか

<p align="right">(<a href="#readme-top">上に戻る</a>)</p>

### RViz2上の可視化

```sh
# 固定ベース
ros2 launch sciurus17_description display.launch.py

# カチャカベース
ros2 launch sciurus17_description display.launch.py use_kachaka_base:=true
```

<p align="right">(<a href="#readme-top">上に戻る</a>)</p>

### シミュレータの実行方法

```sh
# 固定ベース
ros2 launch sciurus17_gazebo sciurus17_gazebo.launch.py

# カチャカベース
ros2 launch sciurus17_gazebo sciurus17_gazebo.launch.py use_kachaka_base:=true
```

固定ベース構成ではロボットはテーブル上に出現します。カチャカベースの場合はテーブルの横の床面に
出現し、`wheel_controller`（`diff_drive_controller`）が速度指令を受け付けます。

<p align="right">(<a href="#readme-top">上に戻る</a>)</p>

## オプション構成要素

頭部、左右の腕、左右のグリッパは個別に取り外せます。組み立て途中のSciurus17でも
同じパッケージで動かせます。いずれもデフォルトは`true`です。

| 引数 | 構成要素 |
| --- | --- |
| `enable_head` | 首のジョイントとヘッドカメラの座標系 |
| `enable_arm_right` | 右腕（およびそのグリッパ） |
| `enable_arm_left` | 左腕（およびそのグリッパ） |
| `enable_gripper_right` | 右グリッパのみ（腕は残す） |
| `enable_gripper_left` | 左グリッパのみ（腕は残す） |

```sh
# 左腕とグリッパのみ（頭部と右腕なし）
ros2 launch sciurus17_examples demo.launch.py \
    enable_head:=false enable_arm_right:=false
```

無効にした構成要素は、URDFのリンクとジョイント、`ros2_control`のジョイント、
SRDFのプランニンググループ、launchファイルのコントローラからそれぞれ取り除かれます。
存在しないハードウェアを参照するものは残りません。

> [!IMPORTANT]
> これらの引数は最上位のlaunchファイルに渡してください。ロボットの記述、MoveIt、
> コントローラへ転送され、3者が同じ構成を参照する必要があります。

> [!NOTE]
> グリッパは腕の手首に取り付くため、腕なしでは成立しません。`enable_arm_right:=false`は
> 右グリッパも取り除きます。腕が無効な状態でグリッパだけを有効にしても効果はありません。

<p align="right">(<a href="#readme-top">上に戻る</a>)</p>

## ベース構成

ロボットの記述は`use_kachaka_base`で選択する2つの構成に対応しています。

| 値 | 構成 |
| --- | --- |
| `false`（デフォルト） | 固定ベース。上半身を静的な`world`座標系に固定します。 |
| `true` | カチャカベース。上半身をカチャカの移動機構が支持します。 |

デフォルト構成はカチャカ関連パッケージに依存しません。

### 座標系の名前

マニピュレータの基準座標系は`body_base_link`です。

カチャカベースを有効にすると、カチャカ側も`base_link`というリンクを持ち込むため、この区別が
重要になります。両者は別の座標系です。

| 座標系 | 意味 |
| --- | --- |
| `body_base_link` | Sciurus17上半身の根本（腕、首、カメラ） |
| `base_link` | カチャカ移動機構の本体（カチャカベース使用時のみ） |

> [!IMPORTANT]
> マニピュレータの目標姿勢は`body_base_link`で指定してください。両構成に存在します。
> 一方`world`はカチャカベース未使用時のみ、`base_link`は使用時のみ存在します。

<p align="right">(<a href="#readme-top">上に戻る</a>)</p>

### リンク構造

**固定ベース（`use_kachaka_base:=false`）**

```
world
  └─ body_base_link
      └─ body_link
          ├─ neck_yaw_link
          ├─ l_link1 (left arm)
          └─ r_link1 (right arm)
```

`world -> body_base_link`はURDFで定義された固定ジョイントのため、`robot_state_publisher`が
配信します。

**カチャカベース（`use_kachaka_base:=true`）**

```
odom
  └─ base_footprint
      └─ base_link (カチャカ移動機構)
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

この構成に`world`リンクは存在しません。`odom -> base_footprint`は`wheel_controller`が
車輪オドメトリから配信し、SRDFもそれに合わせてplanar仮想ジョイントでロボットを固定します。

<p align="right">(<a href="#readme-top">上に戻る</a>)</p>

## パッケージ

- sciurus17_control
  - [README](./sciurus17_control/README.md)
  - Sciurus17の制御を行うパッケージです。カチャカベース用の`wheel_controller`を含みます。
- sciurus17_examples
  - [README](./sciurus17_examples/README.md)
  - Sciurus17のサンプルコード集です。
- sciurus17_examples_py
  - [README](./sciurus17_examples_py/README.md)
  - Sciurus17のPythonサンプルコード集です。
- sciurus17_gazebo
  - Sciurus17のGazeboシミュレーションパッケージです。
- sciurus17_moveit_config
  - Sciurus17の`MoveIt 2`設定ファイルです。SRDFは`use_kachaka_base`に追従できるよう
    `config/sciurus17.srdf.xacro`から生成されます。
- sciurus17_tools
  - Sciurus17を活用するためのオプションツールをまとめたパッケージです。
- sciurus17_vision
  - カメラのlaunchファイルや画像認識を行うノードを定義するパッケージです。
    胸部カメラのキャリブレーションパラメータファイルは
    [chest_camera_info.yaml](./sciurus17_vision/config/chest_camera_info.yaml)です。
- sciurus17_description（外部パッケージ）
  - [README](https://github.com/TeamSOBITS/sciurus17_description/blob/jazzy-devel/README.md)
  - Sciurus17のモデルデータ（xacro）を定義するパッケージです。
- sciurus17_kachaka_description（外部パッケージ、プライベート）
  - カチャカ搭載部と車体フレームのURDFマクロとメッシュです。

<p align="right">(<a href="#readme-top">上に戻る</a>)</p>

## サンプルプログラム

サンプルプログラムは、C++とPythonの両方を用意しています。

- C++ — [sciurus17_examples](./sciurus17_examples/README.md)
- Python — [sciurus17_examples_py](./sciurus17_examples_py/README.md)

<p align="right">(<a href="#readme-top">上に戻る</a>)</p>

## ライセンス

(C) 2018 RT Corporation \<support@rt-net.jp\>

各ファイルにライセンスが明記されている場合、そのライセンスに従います。
特に明記がない場合は、Apache License, Version 2.0に基づいて公開されています。
ライセンスの全文は[LICENSE](./LICENSE)または
[https://www.apache.org/licenses/LICENSE-2.0](https://www.apache.org/licenses/LICENSE-2.0)から
確認できます。

本パッケージが依存する[sciurus17_description](https://github.com/TeamSOBITS/sciurus17_description)には
株式会社アールティの非商用ライセンスが適用されています。詳細は
[sciurus17_description/LICENSE](https://github.com/TeamSOBITS/sciurus17_description/blob/jazzy-devel/LICENSE)を
参照してください。

<p align="right">(<a href="#readme-top">上に戻る</a>)</p>

## コントリビューション

- 本ソフトウェアはオープンソースですが、開発はオープンではありません。
- 本ソフトウェアは基本的にオープンソースソフトウェアとして「AS IS」（現状有姿のまま）で提供しています。
- 本ソフトウェアに関する無償サポートはありません。
- バグの修正や誤字脱字の修正に関するリクエストは常に受け付けていますが、それ以外の機能追加等の
  リクエストについては社内のガイドラインを優先します。

詳しくは[コントリビューションガイドライン](https://github.com/rt-net/.github/blob/master/CONTRIBUTING.md#contribution-guide-ja)に
従ってください。

<p align="right">(<a href="#readme-top">上に戻る</a>)</p>
