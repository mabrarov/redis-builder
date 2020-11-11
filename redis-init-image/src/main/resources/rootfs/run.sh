#!/bin/sh

set -e

j2 --import-env="" \
  --filters "${REDIS_CONFIG_FILTERS_FILE}" \
  -o "${REDIS_CONFIG_FILE}" \
  "${REDIS_CONFIG_TEMPLATE_FILE}"
