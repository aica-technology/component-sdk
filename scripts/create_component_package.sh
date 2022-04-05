#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

COMPONENT_PKG_NAME=""
TEMPLATE_PARENT_DIR=$(readlink -m "${SCRIPT_DIR}"/../source)
COMPONENT_PARENT_DIR=$(readlink -m "${SCRIPT_DIR}"/../source)

HELP_MESSAGE="Usage: ./create_component_package.sh pkg_name [--template-dir <template_pgk_dir>] [-d <destination>]

Create a component package with a desired name from a template package.

Parameters:
  pkg_name                            Name of the package that will contain the components.
                                      Package name 'test' is reserved and can't be used to
                                      name the component package.

Options:
  --template-dir <template_pgk_dir>   Location of the template component package
                                      (default: ${TEMPLATE_PARENT_DIR}).

  -d|--destination                    Desired location of the created component package
                                      (default: ${COMPONENT_PARENT_DIR}).

  -h|--help                           Show this help message.
"

if [[ "$#" -eq 0 ]]; then
  echo "${HELP_MESSAGE}"
  exit 0
fi

while [ "$#" -gt 0 ]; do
  case "$1" in
    --template-dir) TEMPLATE_PARENT_DIR="$2"; shift 2;;
    -d|--destination) COMPONENT_PARENT_DIR="$2"; shift 2;;
    -h|--help) echo -e "\n${HELP_MESSAGE}"; exit 0;;
    *) if [ -z "${COMPONENT_PKG_NAME}" ];then
         COMPONENT_PKG_NAME="$1"
       else
         echo "Only provide one package name"
         echo -e "\n${HELP_MESSAGE}"
         exit 1
       fi; shift 1;;
  esac
done

COMPONENT_DIR="${COMPONENT_PARENT_DIR}/${COMPONENT_PKG_NAME}"

if [[ "${COMPONENT_PKG_NAME}" == "test" ]]; then
  echo "Package name 'test' is reserved. Please consider another name for your component package."
  echo -e "\n${HELP_MESSAGE}"
  exit 1
fi

# check if the component already exists
if [[ -d "${COMPONENT_DIR}" ]]; then
  echo "Component ${COMPONENT_PKG_NAME} already exists in ${COMPONENT_DIR}"
  echo -e "\n${HELP_MESSAGE}"
  exit 1
fi

# copy template_component_package into the component type directory
mkdir -p "${COMPONENT_PARENT_DIR}"
cp -r "${TEMPLATE_PARENT_DIR}"/template_component_package "${COMPONENT_DIR}"

# rename all the template_component_package directories
mv "${COMPONENT_DIR}"/template_component_package "${COMPONENT_DIR}"/"${COMPONENT_PKG_NAME}"
mv "${COMPONENT_DIR}"/include/template_component_package "${COMPONENT_DIR}"/include/"${COMPONENT_PKG_NAME}"

# sed template_component_package in files
if [[ "$OSTYPE" == "darwin"* ]]; then
  sed -i '' "s/template_component_package/${COMPONENT_PKG_NAME}/g" "${COMPONENT_DIR}"/README.md
  sed -i '' "s/template_component_package/${COMPONENT_PKG_NAME}/g" "${COMPONENT_DIR}"/setup.cfg
  sed -i '' "s/template_component_package/${COMPONENT_PKG_NAME}/g" "${COMPONENT_DIR}"/package.xml
  sed -i '' "s/template_component_package/${COMPONENT_PKG_NAME}/g" "${COMPONENT_DIR}"/CMakeLists.txt

  sed -i '' "s/template_component_package/${COMPONENT_PKG_NAME}/g" "${COMPONENT_DIR}"/include/"${COMPONENT_PKG_NAME}"/CPPComponent.h
  sed -i '' "s/template_component_package/${COMPONENT_PKG_NAME}/g" "${COMPONENT_DIR}"/src/CPPComponent.cpp
  sed -i '' "s/template_component_package/${COMPONENT_PKG_NAME}/g" "${COMPONENT_DIR}"/test/cpp_tests/test_cpp_component.cpp

  sed -i '' "s/template_component_package/${COMPONENT_PKG_NAME}/g" "${COMPONENT_DIR}"/"${COMPONENT_PKG_NAME}"/py_component.py
  sed -i '' "s/template_component_package/${COMPONENT_PKG_NAME}/g" "${COMPONENT_DIR}"/test/python_tests/test_py_component.py

  sed -i '' "s/template_component_package/${COMPONENT_PKG_NAME}/g" "${COMPONENT_DIR}"/Dockerfile
  sed -i '' "s/template_component_package/${COMPONENT_PKG_NAME}/g" "${COMPONENT_DIR}"/build-server.sh
else
  sed -i "s/template_component_package/${COMPONENT_PKG_NAME}/g" "${COMPONENT_DIR}"/README.md
  sed -i "s/template_component_package/${COMPONENT_PKG_NAME}/g" "${COMPONENT_DIR}"/setup.cfg
  sed -i "s/template_component_package/${COMPONENT_PKG_NAME}/g" "${COMPONENT_DIR}"/package.xml
  sed -i "s/template_component_package/${COMPONENT_PKG_NAME}/g" "${COMPONENT_DIR}"/CMakeLists.txt

  sed -i "s/template_component_package/${COMPONENT_PKG_NAME}/g" "${COMPONENT_DIR}"/include/"${COMPONENT_PKG_NAME}"/CPPComponent.h
  sed -i "s/template_component_package/${COMPONENT_PKG_NAME}/g" "${COMPONENT_DIR}"/src/CPPComponent.cpp
  sed -i "s/template_component_package/${COMPONENT_PKG_NAME}/g" "${COMPONENT_DIR}"/test/cpp_tests/test_cpp_component.cpp

  sed -i "s/template_component_package/${COMPONENT_PKG_NAME}/g" "${COMPONENT_DIR}"/"${COMPONENT_PKG_NAME}"/py_component.py
  sed -i "s/template_component_package/${COMPONENT_PKG_NAME}/g" "${COMPONENT_DIR}"/test/python_tests/test_py_component.py

  sed -i "s/template_component_package/${COMPONENT_PKG_NAME}/g" "${COMPONENT_DIR}"/Dockerfile
  sed -i "s/template_component_package/${COMPONENT_PKG_NAME}/g" "${COMPONENT_DIR}"/build-server.sh
fi

echo "Component ${COMPONENT_PKG_NAME} created in ${COMPONENT_DIR}."