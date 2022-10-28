ARG BASE_TAG=galactic
FROM ghcr.io/aica-technology/ros2-modulo:${BASE_TAG} as workspace

# set default shell
SHELL ["/bin/bash", "-c"]

# upgrade ament_cmake_python
RUN sudo apt-get update && sudo apt-get install -y ros-${ROS_DISTRO}-ament-cmake-python && sudo rm -rf /var/lib/apt/lists/*

# create a new ROS workspace
USER ${USER}
ENV WORKSPACE ${HOME}/component_ws
ENV COLCON_WORKSPACE ${WORKSPACE}
RUN mkdir -p ${WORKSPACE}/src
WORKDIR ${WORKSPACE}
RUN rosdep update
RUN source ${HOME}/ros2_ws/install/setup.bash && colcon build

# source the new workspace on login
RUN echo "source ${WORKSPACE}/install/setup.bash" | cat - ${HOME}/.bashrc > tmp && mv tmp ${HOME}/.bashrc

WORKDIR ${HOME}

# install the install_component_package script to bin
COPY ./scripts/install_component_package.sh /bin/install_component_package
