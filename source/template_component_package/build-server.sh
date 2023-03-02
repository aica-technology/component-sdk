#!/bin/bash
BASE_IMAGE_TAG=devel

PKG_NAME=template_component_package
IMAGE_NAME="${PKG_NAME//[_]/-}"
IMAGE_TAG=latest

SERVE_REMOTE=false
REMOTE_SSH_PORT=6666

HELP_MESSAGE="Usage: build-server.sh [-d] [--test] [-r] [-v] [-s]
Options:
  -d, --development      Only target the development layer to prevent
                         sources from being built or tested.
  --test                 Invoke the unittest for the component after
                         building. Incompatible with the development
                         option.
  -r, --rebuild          Rebuild the image using the docker
                         --no-cache option.
  -v, --verbose          Use the verbose option during the building
                         process.
  -s, --serve            Start the remove development server.
  -h, --help             Show this help message.
"

BUILD_FLAGS=()
IS_TESTING=false
TARGET=production

while [[ $# -gt 0 ]]; do
  opt="$1"
  case $opt in
    -d|--development) TARGET=development; IMAGE_TAG=development; shift 1;;
    --test) TARGET=test-sources; IS_TESTING=true; shift 1;;
    -r|--rebuild) BUILD_FLAGS+=(--no-cache); shift 1;;
    -v|--verbose) BUILD_FLAGS+=(--progress=plain); shift 1;;
    -s|--serve) SERVE_REMOTE=true; shift;;
    -h|--help) echo "${HELP_MESSAGE}"; exit 0;;
    *) echo "Error in command line parsing" >&2
       echo -e "\n${HELP_MESSAGE}"
       exit 1
  esac
done

# test incompatibility between test and development
if [[ ${IS_TESTING} = true && ${IMAGE_TAG} = "development" ]]; then
  echo "Error in command line arguments:"
  echo "--development and --test options are not compatible."
  exit 1
fi

BUILD_FLAGS+=(--target "${TARGET}")
BUILD_FLAGS+=(--build-arg BASE_TAG="${BASE_IMAGE_TAG}")
BUILD_FLAGS+=(-t "${IMAGE_NAME}:${IMAGE_TAG}")

if [[ "$OSTYPE" != "darwin"* ]]; then
  BUILD_FLAGS+=(--ssh default="${SSH_AUTH_SOCK}")
else
  BUILD_FLAGS+=(--ssh default="$HOME/.ssh/id_rsa")
fi

docker pull ghcr.io/aica-technology/component-sdk:"${BASE_IMAGE_TAG}" || exit 1
DOCKER_BUILDKIT=1 docker build "${BUILD_FLAGS[@]}" . || exit 1

if [ "${SERVE_REMOTE}" = true ]; then
  aica-docker server "${IMAGE_NAME}:${IMAGE_TAG}" -u ros2 -p "${REMOTE_SSH_PORT}"
fi