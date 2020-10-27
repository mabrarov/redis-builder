#!/bin/sh

set -e

export PATH="@j2cli.venv.dir@/bin:${PATH}"

j2 --import-env="" -o /config/redis.conf /template/redis.conf.j2
