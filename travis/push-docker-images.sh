#!/bin/bash

set -e

# Copied from https://github.com/travis-ci/travis-build/blob/master/lib/travis/build/bash/travis_retry.bash
travis_retry() {
  local result=0
  local count=1
  while [[ "${count}" -le 3 ]]; do
    [[ "${result}" -ne 0 ]] && {
      echo -e "\\n${ANSI_RED}The command \"${*}\" failed. Retrying, ${count} of 3.${ANSI_RESET}\\n" >&2
    }
    "${@}" && { result=0 && break; } || result="${?}"
    count="$((count + 1))"
    sleep 1
  done

  [[ "${count}" -gt 3 ]] && {
    echo -e "\\n${ANSI_RED}The command \"${*}\" failed 3 times.${ANSI_RESET}\\n" >&2
  }

  return "${result}"
}

main() {
  travis_retry docker login -u "${DOCKERHUB_USER}" -p "${DOCKERHUB_PASSWORD}"

  mvn --settings "${TRAVIS_BUILD_DIR}/travis/settings.xml" \
    --file "${TRAVIS_BUILD_DIR}/pom.xml" \
    --batch-mode \
    --offline \
    --define docker.push.retries="${DOCKER_PUSH_RETRIES}" \
    docker:push
}

main "${@}"
