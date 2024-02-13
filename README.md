📖 Archiver's note 📖

This repository has been superceded by other resources and is no longer maintained.

In place of this repository, use the new component template to create a new component package.
- https://github.com/aica-technology/component-template

Please refer to the API repository for documentation, schemas and public issues.
- https://github.com/aica-technology/api

The original content of this repository is preserved below.

---

# AICA Component SDK

A software development kit for creating custom components for AICA applications.

## AICA Components

The AICA application framework enables modular programming of robotic systems through the dynamic composition of
Components.

Components are smart, run-time blocks that perform specific functions in an application. Components perform internal
computational logic on data, using input and output signals to communicate with other components. 

Simple components are either "on" or "off"; once created, they publish data on their outputs or execute callbacks
triggered by input data or other events. A simple component might listen on an input signal containing some Cartesian
position data, and re-publish the data with some offset or scaling applied.

Alternately, lifecycle components have managed states and can be configured, activated, or deactivated in stages.
When fully active, they perform a periodic computation step.
An example of a lifecycle component might be a motion generator that outputs a trajectory command when active, where
the trajectory can be paused and resumed by triggering deactivation and activation. 

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
The template contains four empty example components; one simple and one lifecycle component each in C++ and Python.
After creating the component package, these example components should be deleted, modified or replaced with custom
implementations. The following sections describe the steps required to implement a new components in the component package.

## Component package structure

### `./include/<pkg_name>/`
This directory should contain all the C++ headers (`.hpp`) of the package.

### `./src/`
This directory should contain all the C++ source files (`.cpp`) of the package.
They should specify the functions defined in the header files.

### `./<pkg_name>/`
This directory should be a Python module with the same name as the package containing all Python implementations.

### `./test/`
The test directory should contain unit test files for the component package.
Test sources should be named as `test_*.cpp` in the [cpp_tests](./source/template_component_package/test/cpp_tests) folder
for C++ tests using `gtest`, and as `test_*.py` in [python_tests](./source/template_component_package/test/python_tests) for
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
A component should generally inherit from `modulo_components::Component` for simple, unmanaged instances
or `modulo_components::LifecycleComponent` for managed lifecycle instances.

When inheriting from `modulo_components::LifecycleComponent`, lifecycle transition callback functions can be
overridden to implement custom behaviours when the lifecycle state changes. Some common transition functions include:
- `on_configure_callback`
- `on_activate_callback`
- `on_deactivate_callback`

The lifecycle component also provides a step function callback which is executed periodically.
- `on_step_callback`.

The base component classes provide additional virtual functions that can be overridden, as well as many utilities to
add signals, parameters and other behaviours. See the modulo component API documentation for more information.

For the AICA application framework to discover the components, they must be registered.

To register the class as a component, the following macro is needed at the end of the source file,
where `template_component_package` is replaced by the local package name and `CPPComponent` is replaced by the component name:
```cpp
#include "rclcpp_components/register_node_macro.hpp"

RCLCPP_COMPONENTS_REGISTER_NODE(template_component_package::CPPComponent)
```

Then, add the following lines to CMakeLists.txt to generate and register the component library target. 
The target name `cpp_component` can be replaced with any unique identifier for the particular component.
```cmake
ament_auto_add_library(cpp_component SHARED ${PROJECT_SOURCE_DIR}/src/CPPComponent.cpp)
rclcpp_components_register_nodes(cpp_component "${PROJECT_NAME}::CPPComponent")
list(APPEND COMPONENTS cpp_component)
```

## Writing Python components
Similar to C++, a Python component is a class that inherits from either `modulo_components.component.Component` or
`modulo_components.lifecycle_component.LifecycleComponent`.

Refer to the modulo component API documentation for more information.

To register the Python class as a component, add an entrypoint to setup.cfg under the `python_components` field.
Replace `template_component_package` and `PyComponent` with the package and component name respectively.
```
python_components =
    template_component_package::PyComponent = template_component_package.py_component:PyComponent
    
```

## Installing external dependencies
The component build system handles the installation of external dependencies by adding the installation steps in installation config files.

### System libraries
External system dependencies can be installed by adding the installation steps in the [install_dependencies.sh](./source/template_component_package/install_dependencies.sh) script in the created component package.

### Python packages
Python packages can be installed by adding a `requirements.txt` file in the created component package.
It should contain all the needed python modules, eventually tagged by desired version.

## Building a development image
The created component package contains a [Dockerfile](./source/template_component_package/Dockerfile) that installs the component package on top of a development image.
This installs all the needed dependencies and allows to build and test components from an IDE connected in ssh.

To build the development image, run the provided [build-server](./source/template_component_package/build-server.sh) script:
```console
cd source/template_component_package && ./build-server.sh
```
By providing appropriate command line arguments to this script, different stages of the build process can be targeted,
unittests can be run automatically, and a development server to use it in a configured IDE for remote development can
be started automatically. For more details, please refer to the script directly, or execute the script with the `--help` option.

Using the `aica-docker` utility scripts, you can also serve the development image manually:
```console
aica-docker server template-component-pkg:latest -u ros2 -p 6666
```
where the `-p <port>` option can be replaced by any port number available.
