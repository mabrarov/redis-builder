#!/bin/bash

set -e

# shellcheck source=maven.sh
source "${TRAVIS_BUILD_DIR}/travis/maven.sh"

build_maven_project() {
  build_cmd="$(maven_runner)$(maven_settings)$(maven_project_file)$(docker_maven_plugin_version)"
  build_cmd="${build_cmd:+${build_cmd} }--batch-mode"

  if [[ -n "${DOCKERHUB_USER}" ]]; then
    build_cmd="${build_cmd:+${build_cmd} }--define docker.image.registry=$(printf "%q" "${DOCKERHUB_USER}")"
  fi

  if [[ -n "${REDIS_VERSION}" ]]; then
    build_cmd="${build_cmd:+${build_cmd} }--define redis.version=$(printf "%q" "${REDIS_VERSION}")"
  fi

  if [[ -n "${REDIS_SHA256}" ]]; then
    build_cmd="${build_cmd:+${build_cmd} }--define redis.sha256=$(printf "%q" "${REDIS_SHA256}")"
  fi

  if [[ -n "${J2CLI_VERSION}" ]]; then
    build_cmd="${build_cmd:+${build_cmd} }--define j2cli.version=$(printf "%q" "${J2CLI_VERSION}")"
  fi

  build_cmd="${build_cmd:+${build_cmd} }package"

  echo "Building with: ${build_cmd}"
  eval "${build_cmd}"

  docker images
}

wait_for_healthy_container() {
  container_name="${1}"
  wait_seconds=${2}
  exit_code=0
  while true; do
    echo "Waiting for ${container_name} container to become healthy during next ${wait_seconds} seconds"
    container_status="$(docker inspect \
      -f "{{.State.Health.Status}}" "${container_name}")" \
      || exit_code="${?}"
    if [[ "${exit_code}" -ne 0 ]]; then
      echo "Failed to inspect ${container_name} container"
      return 1
    fi
    if [[ "${container_status}" == "healthy" ]]; then
      echo "${container_name} container is healthy"
      return 0
    fi
    if [[ "${wait_seconds}" -le 0 ]]; then
      echo "Timeout waiting for ${container_name} container to become healthy"
      return 1
    fi
    sleep 1
    wait_seconds=$((wait_seconds-1))
  done
}

test_images() {
  project_version_cmd="$(maven_runner)$(maven_settings)$(maven_project_file)"
  project_version_cmd="${project_version_cmd:+${project_version_cmd} }--batch-mode --non-recursive"
  project_version_cmd="${project_version_cmd:+${project_version_cmd} }--define expression=project.version"
  project_version_cmd="${project_version_cmd:+${project_version_cmd} }org.apache.maven.plugins:maven-help-plugin:3.2.0:evaluate"
  maven_project_version="$(eval "${project_version_cmd}" | sed -n -e '/^\[.*\]/ !{ /^[0-9]/ { p; q } }')"

  redis_image_name="${DOCKERHUB_USER}/redis:${REDIS_VERSION}-${maven_project_version}"
  echo "Running container created from ${redis_image_name} image"
  docker run --rm "${redis_image_name}"

  j2cli_image_name="${DOCKERHUB_USER}/j2cli:${J2CLI_VERSION}-${maven_project_version}"
  echo "Running container created from ${j2cli_image_name} image"
  docker run --rm "${j2cli_image_name}"

  docker_compose_project_name="redis"
  export IMAGE_REGISTRY="${DOCKERHUB_USER}"
  export PROJECT_VERSION="${maven_project_version}"

  echo "Creating and starting Redis container using Docker Compose"
  docker-compose \
    -p "${docker_compose_project_name}" \
    -f "${TRAVIS_BUILD_DIR}/docker-compose.yml" \
    up -d

  redis_container_name="$(docker-compose \
    -p "${docker_compose_project_name}" \
    -f "${TRAVIS_BUILD_DIR}/docker-compose.yml" \
    ps -a \
    | sed -r "s/^(${docker_compose_project_name}_redis[^[:space:]]*)[[:space:]]+.*\$/\\1/;t;d")"
  docker_compose_project_network="${docker_compose_project_name}_default"

  wait_for_healthy_container "${redis_container_name}" "${REDIS_START_TIMEOUT}"

  redis_data_key="foo"
  redis_data_value="bar"

  echo "Putting data into Redis: ${redis_data_key} -> ${redis_data_value}"
  docker run --rm \
    --network "${docker_compose_project_network}" \
    "${redis_image_name}" \
    redis-cli -h redis set "${redis_data_key}" "${redis_data_value}"

  echo "Stopping Redis"
  docker-compose \
    -p "${docker_compose_project_name}" \
    -f "${TRAVIS_BUILD_DIR}/docker-compose.yml" \
    stop -t "${REDIS_STOP_TIMEOUT}"

  echo "Starting stopped Redis"
  docker-compose \
    -p "${docker_compose_project_name}" \
    -f "${TRAVIS_BUILD_DIR}/docker-compose.yml" \
    start

  wait_for_healthy_container "${redis_container_name}" "${REDIS_START_TIMEOUT}"

  echo "Reading previously stored data from Redis"
  read_redis_data="$(docker run --rm \
    --network "${docker_compose_project_network}" \
    "${redis_image_name}" \
     redis-cli -h redis get "${redis_data_key}")"

  echo "Read data: ${redis_data_key} -> ${read_redis_data}"
  if [[ "${read_redis_data}" != "${redis_data_value}" ]]; then
    echo "Invalid data read from Redis. Expected: ${redis_data_value}"
    return 1
  fi

  echo "Stopping and removing Redis"
  docker-compose \
    -p "${docker_compose_project_name}" \
    -f "${TRAVIS_BUILD_DIR}/docker-compose.yml" \
    down -v -t 0
}

main() {
  build_maven_project "${@}"
  test_images "${@}"
}

main "${@}"
