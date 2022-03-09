#!/bin/bash

# search for the the directory of the component passed as variable
# there might be subdirectories containing the same name so we only select first occurrence
# tilde extension is used to return absolute path for subsequent finds
function install_dependencies() {
    COMPONENT_DIR="$(find ~+ -type d -name "$1" -print -quit)"

    if [ -z "${COMPONENT_DIR}" ]; then
        echo "Component not found"
        exit 1
    fi

    # there are for now two type of dependencies, python requirement.txt and install scripts
    PYTHON_DEP=( "$(find "${COMPONENT_DIR}" -type f -name "requirements.txt")" )
    for DEP in "${PYTHON_DEP[@]}"
    do
        if [ -n "${DEP}" ]; then
          echo "Running pip install on requirement file: ${DEP}"
          pip install --upgrade -r "${DEP}"
        fi
    done

    # follow by installing the install script if provided
    INSTALL_SCRIPT=( "$(find "${COMPONENT_DIR}" -type f -name "install_dependencies.sh")" )
    for SCRIPT in "${INSTALL_SCRIPT[@]}"
    do
        if [ -n "${SCRIPT}" ]; then
            cd "${COMPONENT_DIR}" || exit 1
            echo "Running install script: ${SCRIPT}"
            bash "${SCRIPT}" || exit 1
        fi
    done
}

CURRENT_DIR=$(pwd)
COMPONENT_PKG=$1

if [ -n "${COMPONENT_PKG}" ]; then
  cd "${CURRENT_DIR}" || exit 1
  echo "Installing dependencies for component ${COMPONENT_PKG}"
  install_dependencies "${COMPONENT_PKG}"
fi
