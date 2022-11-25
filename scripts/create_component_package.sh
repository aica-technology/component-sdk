#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
SDK_DIR=$(dirname "${SCRIPT_DIR}")
TEMPLATE_DIR="${SDK_DIR}"/source/template_component_package
DESTINATION_DIR="${SDK_DIR}"/source

COMPONENT_PKG_NAME=""

HELP_MESSAGE="Usage: ./create_component_package.sh pkg_name [-d <destination>] [--template-dir <template_pkg_dir>]

Create a component package with a desired name from a template package.

Parameters:
  pkg_name                            Name of the package that will contain the components.
                                      Package name 'test' is reserved and can't be used to
                                      name the component package.

Options:
  -d|--destination                    Desired location of the created component package.
                                      Default: ${DESTINATION_DIR}

  --template-dir <template_pgk_dir>   Location of the template component package.
                                      Default: ${TEMPLATE_DIR}

  -h|--help                           Show this help message.
"

if [[ "$#" -eq 0 ]]; then
  echo "${HELP_MESSAGE}"
  exit 0
fi

while [ "$#" -gt 0 ]; do
  case "$1" in
    --template-dir) TEMPLATE_DIR="$2"; shift 2;;
    -d|--destination) DESTINATION_DIR="$2"; shift 2;;
    -h|--help) echo -e "\n${HELP_MESSAGE}"; exit 0;;
    *) if [ -z "${COMPONENT_PKG_NAME}" ]; then
         COMPONENT_PKG_NAME="$1"
       else
         echo "Only provide one package name"
         echo -e "\n${HELP_MESSAGE}"
         exit 1
       fi; shift 1;;
  esac
done

if [ -z "${COMPONENT_PKG_NAME}" ]; then
  echo "A component package name must be provided"
  echo -e "\n${HELP_MESSAGE}"
  exit 1
elif [[ "${COMPONENT_PKG_NAME}" == "test" ]]; then
  echo "Package name 'test' is reserved. Please consider another name for your component package."
  echo -e "\n${HELP_MESSAGE}"
  exit 1
fi

COMPONENT_PKG_DIR="${DESTINATION_DIR}/${COMPONENT_PKG_NAME}"

# check if the component already exists
if [[ -d "${COMPONENT_PKG_DIR}" ]]; then
  echo "Directory ${COMPONENT_PKG_DIR} already exists!"
  echo -e "\n${HELP_MESSAGE}"
  exit 1
fi

# copy template_component_package into the destination directory
mkdir -p "${DESTINATION_DIR}"
cp -r "${TEMPLATE_DIR}" "${COMPONENT_PKG_DIR}"

# rename all the template_component_package directories
mv "${COMPONENT_PKG_DIR}"/template_component_package "${COMPONENT_PKG_DIR}"/"${COMPONENT_PKG_NAME}"
mv "${COMPONENT_PKG_DIR}"/include/template_component_package "${COMPONENT_PKG_DIR}"/include/"${COMPONENT_PKG_NAME}"

# rename the template component descriptions
DESCRIPTION_DIR="${COMPONENT_PKG_DIR}"/component_descriptions
mv "${DESCRIPTION_DIR}"/template_component_package_cpp_component.json "${DESCRIPTION_DIR}"/"${COMPONENT_PKG_NAME}"_cpp_component.json
mv "${DESCRIPTION_DIR}"/template_component_package_cpp_lifecycle_component.json "${DESCRIPTION_DIR}"/"${COMPONENT_PKG_NAME}"_cpp_lifecycle_component.json
mv "${DESCRIPTION_DIR}"/template_component_package_py_component.json "${DESCRIPTION_DIR}"/"${COMPONENT_PKG_NAME}"_py_component.json
mv "${DESCRIPTION_DIR}"/template_component_package_py_lifecycle_component.json "${DESCRIPTION_DIR}"/"${COMPONENT_PKG_NAME}"_py_lifecycle_component.json

# sed template_component_package in files
if [[ "$OSTYPE" == "darwin"* ]]; then
  sed -i '' "s/template_component_package/${COMPONENT_PKG_NAME}/g" "${COMPONENT_PKG_DIR}"/README.md
  sed -i '' "s/template_component_package/${COMPONENT_PKG_NAME}/g" "${COMPONENT_PKG_DIR}"/setup.cfg
  sed -i '' "s/template_component_package/${COMPONENT_PKG_NAME}/g" "${COMPONENT_PKG_DIR}"/package.xml
  sed -i '' "s/template_component_package/${COMPONENT_PKG_NAME}/g" "${COMPONENT_PKG_DIR}"/CMakeLists.txt

  sed -i '' "s/template_component_package/${COMPONENT_PKG_NAME}/g" "${COMPONENT_PKG_DIR}"/include/"${COMPONENT_PKG_NAME}"/CPPComponent.hpp
  sed -i '' "s/template_component_package/${COMPONENT_PKG_NAME}/g" "${COMPONENT_PKG_DIR}"/src/CPPComponent.cpp
  sed -i '' "s/template_component_package/${COMPONENT_PKG_NAME}/g" "${COMPONENT_PKG_DIR}"/test/cpp_tests/test_cpp_component.cpp

  sed -i '' "s/template_component_package/${COMPONENT_PKG_NAME}/g" "${COMPONENT_PKG_DIR}"/include/"${COMPONENT_PKG_NAME}"/CPPLifecycleComponent.hpp
  sed -i '' "s/template_component_package/${COMPONENT_PKG_NAME}/g" "${COMPONENT_PKG_DIR}"/src/CPPLifecycleComponent.cpp
  sed -i '' "s/template_component_package/${COMPONENT_PKG_NAME}/g" "${COMPONENT_PKG_DIR}"/test/cpp_tests/test_cpp_lifecycle_component.cpp

  sed -i '' "s/template_component_package/${COMPONENT_PKG_NAME}/g" "${COMPONENT_PKG_DIR}"/"${COMPONENT_PKG_NAME}"/py_component.py
  sed -i '' "s/template_component_package/${COMPONENT_PKG_NAME}/g" "${COMPONENT_PKG_DIR}"/test/python_tests/test_py_component.py

  sed -i '' "s/template_component_package/${COMPONENT_PKG_NAME}/g" "${COMPONENT_PKG_DIR}"/"${COMPONENT_PKG_NAME}"/py_lifecycle_component.py
  sed -i '' "s/template_component_package/${COMPONENT_PKG_NAME}/g" "${COMPONENT_PKG_DIR}"/test/python_tests/test_py_lifecycle_component.py

  sed -i '' "s/template_component_package/${COMPONENT_PKG_NAME}/g" "${DESCRIPTION_DIR}"/"${COMPONENT_PKG_NAME}"_cpp_component.json
  sed -i '' "s/template_component_package/${COMPONENT_PKG_NAME}/g" "${DESCRIPTION_DIR}"/"${COMPONENT_PKG_NAME}"_cpp_lifecycle_component.json
  sed -i '' "s/template_component_package/${COMPONENT_PKG_NAME}/g" "${DESCRIPTION_DIR}"/"${COMPONENT_PKG_NAME}"_py_component.json
  sed -i '' "s/template_component_package/${COMPONENT_PKG_NAME}/g" "${DESCRIPTION_DIR}"/"${COMPONENT_PKG_NAME}"_py_lifecycle_component.json

  sed -i '' "s/template_component_package/${COMPONENT_PKG_NAME}/g" "${COMPONENT_PKG_DIR}"/Dockerfile
  sed -i '' "s/template_component_package/${COMPONENT_PKG_NAME}/g" "${COMPONENT_PKG_DIR}"/build-server.sh
else
  sed -i "s/template_component_package/${COMPONENT_PKG_NAME}/g" "${COMPONENT_PKG_DIR}"/README.md
  sed -i "s/template_component_package/${COMPONENT_PKG_NAME}/g" "${COMPONENT_PKG_DIR}"/setup.cfg
  sed -i "s/template_component_package/${COMPONENT_PKG_NAME}/g" "${COMPONENT_PKG_DIR}"/package.xml
  sed -i "s/template_component_package/${COMPONENT_PKG_NAME}/g" "${COMPONENT_PKG_DIR}"/CMakeLists.txt

  sed -i "s/template_component_package/${COMPONENT_PKG_NAME}/g" "${COMPONENT_PKG_DIR}"/include/"${COMPONENT_PKG_NAME}"/CPPComponent.hpp
  sed -i "s/template_component_package/${COMPONENT_PKG_NAME}/g" "${COMPONENT_PKG_DIR}"/src/CPPComponent.cpp
  sed -i "s/template_component_package/${COMPONENT_PKG_NAME}/g" "${COMPONENT_PKG_DIR}"/test/cpp_tests/test_cpp_component.cpp

  sed -i "s/template_component_package/${COMPONENT_PKG_NAME}/g" "${COMPONENT_PKG_DIR}"/include/"${COMPONENT_PKG_NAME}"/CPPLifecycleComponent.hpp
  sed -i "s/template_component_package/${COMPONENT_PKG_NAME}/g" "${COMPONENT_PKG_DIR}"/src/CPPLifecycleComponent.cpp
  sed -i "s/template_component_package/${COMPONENT_PKG_NAME}/g" "${COMPONENT_PKG_DIR}"/test/cpp_tests/test_cpp_lifecycle_component.cpp

  sed -i "s/template_component_package/${COMPONENT_PKG_NAME}/g" "${COMPONENT_PKG_DIR}"/"${COMPONENT_PKG_NAME}"/py_component.py
  sed -i "s/template_component_package/${COMPONENT_PKG_NAME}/g" "${COMPONENT_PKG_DIR}"/test/python_tests/test_py_component.py

  sed -i "s/template_component_package/${COMPONENT_PKG_NAME}/g" "${COMPONENT_PKG_DIR}"/"${COMPONENT_PKG_NAME}"/py_lifecycle_component.py
  sed -i "s/template_component_package/${COMPONENT_PKG_NAME}/g" "${COMPONENT_PKG_DIR}"/test/python_tests/test_py_lifecycle_component.py

  sed -i "s/template_component_package/${COMPONENT_PKG_NAME}/g" "${DESCRIPTION_DIR}"/"${COMPONENT_PKG_NAME}"_cpp_component.json
  sed -i "s/template_component_package/${COMPONENT_PKG_NAME}/g" "${DESCRIPTION_DIR}"/"${COMPONENT_PKG_NAME}"_cpp_lifecycle_component.json
  sed -i "s/template_component_package/${COMPONENT_PKG_NAME}/g" "${DESCRIPTION_DIR}"/"${COMPONENT_PKG_NAME}"_py_component.json
  sed -i "s/template_component_package/${COMPONENT_PKG_NAME}/g" "${DESCRIPTION_DIR}"/"${COMPONENT_PKG_NAME}"_py_lifecycle_component.json

  sed -i "s/template_component_package/${COMPONENT_PKG_NAME}/g" "${COMPONENT_PKG_DIR}"/Dockerfile
  sed -i "s/template_component_package/${COMPONENT_PKG_NAME}/g" "${COMPONENT_PKG_DIR}"/build-server.sh
fi

echo "Component ${COMPONENT_PKG_NAME} created in ${DESTINATION_DIR}."