#!/bin/sh

set -e

export PATH="@j2cli.venv.dir@/bin:${PATH}"

j2 --import-env="" -o "${REDIS_CONFIG_DIR}/redis.conf" "${REDIS_CONFIG_TEMPLATE_DIR}/redis.conf.j2"
