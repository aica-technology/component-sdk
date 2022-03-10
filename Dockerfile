ARG ROS_VERSION=galactic
FROM ghcr.io/aica-technology/ros2-modulo:${ROS_VERSION} as workspace

# set default shell
SHELL ["/bin/bash", "-c"]

# copy the script folder
COPY --chown=${USER} ./scripts ${HOME}/scripts

# create a new ROS workspace
USER ${USER}
ENV WORKSPACE ${HOME}/component_ws
RUN mkdir -p ${WORKSPACE}/src
WORKDIR ${WORKSPACE}

# upgrade ament_cmake_python
RUN sudo apt update && sudo apt install -y ros-${ROS_DISTRO}-ament-cmake-python && sudo rm -rf /var/lib/apt/lists/*

RUN /bin/bash -c "source ${HOME}/ros2_ws/install/setup.bash; colcon build"

# update rosdep and apt package lists
RUN sudo apt-get update && rosdep update

# source the new workspace on login
RUN echo "source ${WORKSPACE}/install/setup.bash" | cat - ${HOME}/.bashrc > tmp && mv tmp ${HOME}/.bashrc
