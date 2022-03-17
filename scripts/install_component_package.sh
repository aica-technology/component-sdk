#!/bin/bash

# search for the the directory of the component passed as variable
# there might be subdirectories containing the same name so we only select first occurrence
# tilde extension is used to return absolute path for subsequent finds
function install_dependencies() {
    COMPONENT_DIR="$(find ~+ -type d -name "$1" -print -quit)"
    DESTINATION_DIR="$2"

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

    # eventually move the folder to the destination
    if [ -n "${DESTINATION_DIR}" ]; then
      echo "Moving component from ${COMPONENT_DIR} to ${DESTINATION_DIR}"
      cp -r "${COMPONENT_DIR}" "${DESTINATION_DIR}"
    fi
}

HELP_MESSAGE="
Usage: ./install_component_package.sh <pkg_names> -d <destination>

Install a component package or a list of component packages to a certain directory, if
provided a destination. This script will find and execute any 'install_dependencies.sh'
scripts that contain the commands to install system dependencies as well as find and
install any python packages provided in 'requirements.txt' files.

Options:
  pkg_names                         Name or list of names of the package(s)
                                    that should be installed.

  -d, --destination <destination>   The package(s) will be moved to the
                                    specified directory (path can be absolute
                                    or relative).

  --force                           Force the component package and its dependencies
                                    to be reinstalled if it already exists.

  -h, --help                        Show this help message.
"

CURRENT_DIR=$(pwd)

DESTINATION_DIR=""
FORCE=0
COMPONENT_LIST=()

if [[ "$#" -eq 0 ]]; then
  echo "${HELP_MESSAGE}"
  exit 0
fi

while [ "$#" -gt 0 ]; do
  case "$1" in
    -d|--destination) DESTINATION_DIR="$2"; shift 2;;
    --force) FORCE=1; shift 1;;
    -h|--help) echo "${HELP_MESSAGE}"; exit 0;;
    *) COMPONENT_LIST+=("$1"); shift 1;;
  esac
done

# expand the path if it is relative
if [ -n "${DESTINATION_DIR}" ]; then
  if [[ ! "${DESTINATION_DIR}" = /* ]]; then
    DESTINATION_DIR="${CURRENT_DIR}/${DESTINATION_DIR}"
  fi
  mkdir -p "${DESTINATION_DIR}"
else
  echo "No destination directory for the installation of the component package provided."
  echo "${HELP_MESSAGE}" && exit 1
fi

for COMPONENT in "${COMPONENT_LIST[@]}"; do
  if [ -n "${COMPONENT}" ]; then
    cd "${CURRENT_DIR}" || exit 1
    if [ "$(ls -A ${DESTINATION_DIR}/${COMPONENT})" ] && [ "${FORCE}" -eq 0 ]; then
      echo "There already exists a component package named '${COMPONENT}'"
      echo "in destination '${DESTINATION_DIR}'. Please use the '--force'"
      echo "option if you wish to reinstall the component package and its dependencies." && exit 0
    else
      echo "Installing dependencies for component ${COMPONENT}"
      install_dependencies "${COMPONENT}" "${DESTINATION_DIR}"
    fi
  fi
done