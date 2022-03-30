ARG ROS_VERSION=galactic
FROM ghcr.io/aica-technology/ros2-modulo:${ROS_VERSION} as workspace

# upgrade ament_cmake_python
RUN sudo apt-get update && sudo apt-get install -y ros-${ROS_DISTRO}-ament-cmake-python && sudo rm -rf /var/lib/apt/lists/*

# copy the template component package and the create_component_package script
COPY --chown=${USER} ./source/template_component_package ${HOME}/component-sdk/template_component_package
COPY --chown=${USER} ./scripts/create_component_package.sh ${HOME}/component-sdk

# install the install_component_package script to bin
USER root
COPY ./scripts/install_component_package.sh /bin/install_component_package
USER ${USER}

# create a new ROS workspace
USER ${USER}
ENV WORKSPACE ${HOME}/component_ws
RUN mkdir -p ${WORKSPACE}/src
WORKDIR ${WORKSPACE}
RUN rosdep update
RUN /bin/bash -c "source ${HOME}/ros2_ws/install/setup.bash; colcon build"

# source the new workspace on login
RUN echo "source ${WORKSPACE}/install/setup.bash" | cat - ${HOME}/.bashrc > tmp && mv tmp ${HOME}/.bashrc

WORKDIR ${HOME}
