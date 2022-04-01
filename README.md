# component-sdk
A software development kit for creating custom components for AICA applications.

## Creating a component package
To create a component package, you should use the [create_component_package.sh](./scripts/create_component_package.sh)
script, with the desired package name `<pkg_name>`.
For example, to create the `foo` component package:
```console
./scripts/create_component_package.sh foo
```
This will copy the template package [template_component_package](./source/template_component_package) in the [source](./source) folder, and
rename all the occurrences of `template_component_package` to `foo`.

It's also possible to copy the template package to a different location, by providing a *destination* option:
```console
./scrips/create_component_package.sh foo --destination /path/to/location
```
or just
```console
./scrips/create_component_package.sh foo -d /path/to/location
```

Components can be implemented in C++ or Python. A component package can contain multiple components in either language.
The following sections describe the steps required to implement a new components in the component package.

## Component package structure

### `./include/<pkg_name>/`
This directory should contain all the C++ headers (`.h`) of the package.

### `./src/`
This directory should contain all the C++ source files (`.cpp`) of the package.
They should specify the functions defined in the header files.

### `./<pkg_name>/`
This directory should be a Python module with the same name as the package containing all Python implementations.

### `./test/`
The test directory should contain unit test files for the component package.
Test sources should be named as `test_*.cpp` in the [cpp_tests](./source/template_component_package/test/cpp_tests) folder
for C++ tests using `gtest` and as `test_*.py` in [python_tests](./source/template_component_package/test/python_tests) for
Python tests using `pytest`.

### `./CMakeLists.txt`
Contains package build instructions. Change this file when adding components as described in
[Writing C++ Components](#writing-c-components) and [Writing Python Components](#writing-python-components).

### `./package.xml`
This is a ROS 2 specific file that describe the package metadata and dependencies.
See the [ROS 2 documentation](https://docs.ros.org/en/foxy/Tutorials/Creating-Your-First-ROS2-Package.html) for
additional details.

### `./setup.cfg`
Contains the entrypoints as described in [Writing Python Components](#writing-python-components).

## Writing C++ components
A component should generally inherit from `rlcpp::Node` for simple, unmanaged instances or `modulo_core::Component`
for managed lifecycle instances.

When inheriting from `modulo_core::Component`, basic functions can be overridden for desired behavior.
The most common are `on_configure`, `on_activate`, and `step`.
See [CPPComponent.h](./source/template_component_package/include/template_component_package/CPPComponent.h) for an example.

To register the class as a component, the following export macro is needed at the end of each source file
where `CPPComponent` is replaced by the component name:
```cpp
#include "rclcpp_components/register_node_macro.hpp"

RCLCPP_COMPONENTS_REGISTER_NODE(template_component::CPPComponent)
```
See [CPPComponent.cpp](./source/template_component_package/src/CPPComponent.cpp) for an example.

## Writing Python components
As in C++ a Python component is a class that inherits from either `rclpy.node.Node`, or
`base_components.component.Component`.

When inheriting from `base_components.component.Component`, basic functions can be overridden for desired behavior.
The most common are `on_configure`, `on_activate`, and `_step`.
See [py_component.py](./source/template_component_package/template_component_package/py_component.py) for an example.

To enable the export of the nodes and components, one needs to add the entry points in
[setup.cfg](./source/template_component_package/setup.cfg).

## Installing external dependencies
The component build system handles the installation of external dependencies by adding the installation steps in installation config files.

### System libraries
External system dependencies can be installed by adding the installation steps in the [install_dependencies.sh](./source/template_component_package/install_dependencies.sh) script in the created component package.

### Python packages
Python packages can be installed by adding a `requirements.txt` file in the create component package.
It should contain all the needed python modules, eventually tagged by desired version.

## Building a development image
The created component package contains a [Dockerfile](./source/template_component_package/Dockerfile) that installs the component package on top of a development image.
This installs all the needed dependencies and allows to build and test components from an IDE connected in ssh.

To build the development image for the `template_component_package` you would run:
```console
cd source/template_component_package && DOCKER_BUILDKIT=1 docker build . -t template-component-pkg-dev:latest
```
where `template-component-pkg-dev:latest` is the name and tag you desire for your local image.

Using the `aica-docker` utility scripts, you can serve the development image to use it in a configured IDE for remote development:
```console
aica-docker server template-component-pkg-dev:latest -u ros2 -p 5550
```
where the `-p <port>` option can be replaced by any port number available.