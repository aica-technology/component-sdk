ARG ROS_VERSION=galactic
FROM component-sdk:${ROS_VERSION} as development
WORKDIR ${WORKSPACE}

ARG COMPONENT_PKG=template_component_package
# copy the script folder
COPY --chown=${USER} ./ ${WORKSPACE}/src/${COMPONENT_PKG}

# install the source folder and their dependencies
USER root
RUN --mount=type=ssh ${HOME}/scripts/install_component_package.sh ${COMPONENT_PKG}
RUN chown -R ${USER}:${USER} ${WORKSPACE}/src
USER ${USER}

# install all rosdep dependencies and clean image
RUN sudo apt-get update \
  && rosdep install --from-paths ${WORKSPACE}/src --ignore-src -r -y \
  && sudo apt-get clean \
  && sudo rm -rf /var/lib/apt/lists/* \
  && sudo rm -rf /tmp/*


FROM development as production
WORKDIR ${WORKSPACE}
# install all dependencies and build the component workspace
RUN /bin/bash -c "source ${WORKSPACE}/install/setup.bash; colcon build --symlink-install"


FROM production as test-sources
WORKDIR ${WORKSPACE}

RUN /bin/bash -c "source ${WORKSPACE}/install/setup.bash; colcon test --return-code-on-test-failure"


FROM development as runtime
WORKDIR ${WORKSPACE}

# Clean image
RUN sudo apt-get clean && sudo rm -rf /var/lib/apt/lists/* && sudo rm -rf /tmp/*
