#!/bin/bash
if [ -z "${COMPONENTS_INSTALL_DIRECTORY}" ]; then
  COMPONENTS_INSTALL_DIRECTORY=/tmp/components_installation
fi
mkdir -p "${COMPONENTS_INSTALL_DIRECTORY}" && cd "${COMPONENTS_INSTALL_DIRECTORY}" || exit 1

# install any system dependencies using sudo apt get commands

cd ${COMPONENTS_INSTALL_DIRECTORY} && rm -rf ./* || exit 1
