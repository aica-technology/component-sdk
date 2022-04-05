ARG BASE_TAG=latest
FROM ghcr.io/aica-technology/component-sdk:${BASE_TAG} as development
WORKDIR /tmp

ARG COMPONENT_PKG=template_component_package
# copy the script folder
COPY --chown=${USER} ./ ./${COMPONENT_PKG}

# install the source folder and their dependencies
USER root
RUN --mount=type=ssh install_component_package ${COMPONENT_PKG} --destination ${WORKSPACE}/src
RUN chown -R ${USER}:${USER} ${WORKSPACE}/src
USER ${USER}

# install all rosdep dependencies and clean image
RUN sudo apt-get update \
  && rosdep install --from-paths ${WORKSPACE}/src --ignore-src -r -y \
  && sudo apt-get clean \
  && sudo rm -rf /var/lib/apt/lists/* \
  && sudo rm -rf /tmp/*

WORKDIR ${WORKSPACE}


FROM development as production
# install all dependencies and build the component workspace
RUN /bin/bash -c "source ${WORKSPACE}/install/setup.bash; colcon build --symlink-install"


FROM production as test-sources
# run the unit tests of the built workspace
RUN /bin/bash -c "source ${WORKSPACE}/install/setup.bash; colcon test --return-code-on-test-failure"
