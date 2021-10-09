# Redis Docker Image Builder

[![Release](https://img.shields.io/github/release/mabrarov/redis-builder.svg)](https://github.com/mabrarov/redis-builder/releases/latest)
[![License](https://img.shields.io/github/license/mabrarov/redis-builder)](https://github.com/mabrarov/redis-builder/tree/master/LICENSE)
[![Travis CI build status](https://travis-ci.com/mabrarov/redis-builder.svg?branch=master)](https://travis-ci.com/github/mabrarov/redis-builder)

Builder of Docker image with [Redis](https://github.com/redis/redis) using
["Distroless" Docker Image](https://github.com/GoogleContainerTools/distroless) as a base image.

## Building

### Building Requirements

1. JDK 1.8+
1. Docker 19.03.12+
1. If remote Docker instance is used then `DOCKER_HOST` environment variable should point to that
   engine and include the schema, like `tcp://docker-host:2375` instead of `docker-host:2375`.
1. The current directory is a directory where this repository is cloned.

### Building Steps

Building with [Maven Wrapper](https://github.com/takari/maven-wrapper):

```bash
./mvnw clean package
```

or on Windows:

```bash
mvnw.cmd clean package
```

## Testing

1. Redis version

   ```bash
   docker run --rm abrarov/redis:6.2.1-1.1.0
   ```

   Expected output looks like:

   ```text
   Redis server v=6.2.1 sha=00000000:0 malloc=jemalloc-5.1.0 bits=64 build=a93dda0c16dc7a5c
   ```

1. [Redis CLI](https://github.com/redis/redis#playing-with-redis)

   ```bash
   container_id="$(docker run -d abrarov/redis:6.2.1-1.1.0 redis-server)" && \
   docker exec "${container_id}" redis-cli ping && \
   docker rm -fv "${container_id}" > /dev/null
   ```

   Expected output is:

   ```text
   PONG
   ```

1. j2cli version

   ```bash
   docker run --rm abrarov/j2cli:0.3.10-1.1.0
   ```

   Expected output is:

   ```text
   j2cli 0.3.10, Jinja2 2.11.3
   ```

## Docker Compose

Assuming the current directory is a directory where this repository is cloned.

* Start

   ```bash
   docker-compose -p redis up -d
   ```

* Test connection to Redis

   ```bash
   docker run --rm --network redis_default abrarov/redis:6.2.1-1.1.0 redis-cli -h redis ping
   ```

   Expected output is:
  
   ```text
   PONG
   ```

* Put some data into Redis

   ```bash
   docker run --rm --network redis_default abrarov/redis:6.2.1-1.1.0 redis-cli -h redis set foo bar
   ```

   Expected output is:
  
   ```text
   OK
   ```

* Stop without removal

   ```bash
   docker-compose -p redis stop -t 120
   ```

* Start stopped instances

   ```bash
   docker-compose -p redis start
   ```

* Test persistence of stored data

   ```bash
   docker run --rm --network redis_default abrarov/redis:6.2.1-1.1.0 redis-cli -h redis get foo
   ```

   Expected output is:
  
   ```text
   bar
   ```

* Stop immediately and remove

   ```bash
   docker-compose -p redis down -v -t 0
   ```
