#!/bin/bash

set -e

build_maven_project() {
  if [[ "${MAVEN_WRAPPER}" -ne 0 ]]; then
    build_cmd="${build_cmd:+${build_cmd} }$(printf "%q" "${TRAVIS_BUILD_DIR}/mvnw")"
  else
    build_cmd="${build_cmd:+${build_cmd} }mvn"
  fi

  build_cmd="${build_cmd:+${build_cmd} }-s $(printf "%q" "${TRAVIS_BUILD_DIR}/travis/settings.xml")"
  build_cmd="${build_cmd:+${build_cmd} }-f $(printf "%q" "${TRAVIS_BUILD_DIR}/pom.xml")"
  build_cmd="${build_cmd:+${build_cmd} }--batch-mode package"

  if [[ "${DOCKER_MAVEN_PLUGIN_VERSION}" != "" ]]; then
    build_cmd="${build_cmd:+${build_cmd} }-D docker-maven-plugin.version=$(printf "%q" "${DOCKER_MAVEN_PLUGIN_VERSION}")"
  fi

  if [[ "${DOCKERHUB_USER}" != "" ]]; then
    build_cmd="${build_cmd:+${build_cmd} }-D docker.image.registry=$(printf "%q" "${DOCKERHUB_USER}")"
  fi

  if [[ "${REDIS_VERSION}" != "" ]]; then
    build_cmd="${build_cmd:+${build_cmd} }-D redis.version=$(printf "%q" "${REDIS_VERSION}")"
  fi

  if [[ "${REDIS_SHA256}" != "" ]]; then
    build_cmd="${build_cmd:+${build_cmd} }-D redis.sha256=$(printf "%q" "${REDIS_SHA256}")"
  fi

  echo "Building with: ${build_cmd}"
  eval "${build_cmd}"

  docker images
}

test_images() {
  maven_project_version="$(mvn -f "${TRAVIS_BUILD_DIR}/pom.xml" \
    org.apache.maven.plugins:maven-help-plugin:3.2.0:evaluate \
    -D expression=project.version \
    | sed -n -e '/^\[.*\]/ !{ /^[0-9]/ { p; q } }')"

  image_name="${DOCKERHUB_USER}/redis:${REDIS_VERSION}-${maven_project_version}"
  echo "Running container created from ${image_name} image"
  docker run --rm "${image_name}"
}

main() {
  build_maven_project "${@}"
  test_images "${@}"
}

main "${@}"
