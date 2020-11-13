#!/bin/bash

set -e

# shellcheck source=maven.sh
source "${TRAVIS_BUILD_DIR}/travis/maven.sh"
# shellcheck source=travis-retry.sh
source "${TRAVIS_BUILD_DIR}/travis/travis-retry.sh"

main() {
  travis_retry docker login -u "${DOCKERHUB_USER}" -p "${DOCKERHUB_PASSWORD}"

  push_cmd="$(maven_runner)$(maven_settings)$(maven_project_file)$(docker_maven_plugin_version)"
  push_cmd="${push_cmd:+${push_cmd} }--batch-mode"
  push_cmd="${push_cmd:+${push_cmd} }--define docker.push.retries=$(printf "%q" "${DOCKER_PUSH_RETRIES}")"
  push_cmd="${push_cmd:+${push_cmd} }docker:push"

  echo "Pushing images with: ${push_cmd}"
  eval "${push_cmd}"
}

main "${@}"
