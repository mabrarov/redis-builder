# Redis Docker Image Builder

[![Release](https://img.shields.io/github/release/mabrarov/redis-builder.svg)](https://github.com/mabrarov/redis-builder/releases/latest)
[![License](https://img.shields.io/github/license/mabrarov/redis-builder)](https://github.com/mabrarov/redis-builder/tree/master/LICENSE)
[![Travis CI build status](https://travis-ci.org/mabrarov/redis-builder.svg?branch=master)](https://travis-ci.org/mabrarov/redis-builder)

Builder of Docker image with [Redis](https://github.com/redis/redis) using
["Distroless" Docker Image](https://github.com/GoogleContainerTools/distroless) as a base image.

## Building

### Building Requirements

1. JDK 1.8+
1. Docker 1.12+
1. If remote Docker instance is used then `DOCKER_HOST` environment variable should point to that
   engine and include the schema, like `tcp://docker-host:2375` instead of `docker-host:2375`.
1. The current directory is a directory where this repository is cloned.
1. docker-maven-plugin 0.34-SNAPSHOT from
   [copy_mojo](https://github.com/mabrarov/docker-maven-plugin/tree/copy_mojo) branch
   of [mabrarov/docker-maven-plugin](https://github.com/mabrarov/docker-maven-plugin) GitHub project
   is built and installed into the local Maven repository.

### Building Steps

Building with [Maven Wrapper](https://github.com/takari/maven-wrapper):

```bash
./mvnw clean package -Ddocker-maven-plugin.version=0.34-SNAPSHOT
```

or on Windows:

```bash
mvnw.cmd clean package -Ddocker-maven-plugin.version=0.34-SNAPSHOT
```

## Testing

1. Redis version

   ```bash
   docker run --rm abrarov/redis:6.0.9-1.0.0
   ```

   Expected output looks like:

   ```text
   Redis server v=6.0.9 sha=00000000:0 malloc=jemalloc-5.1.0 bits=64 build=e9b33d1e886db04a
   ```

1. [Redis CLI](https://github.com/redis/redis#playing-with-redis)

   ```bash
   container_id="$(docker run -d abrarov/redis:6.0.9-1.0.0 redis-server)" && \
   docker exec -it "${container_id}" redis-cli ping && \
   docker rm -fv "${container_id}" > /dev/null
   ```

   Expected output is:

   ```text
   PONG
   ```

1. j2cli version

   ```bash
   docker run --rm abrarov/j2cli:0.3.10-1.0.0
   ```

   Expected output is:

   ```text
   j2cli 0.3.10, Jinja2 2.11.2
   ```

## Docker Compose

Assuming the current directory is a directory where this repository is cloned.

* Start

   ```bash
   docker-compose -p redis up -d
   ```

* Test connection to Redis

   ```bash
   docker run --rm --network redis_default abrarov/redis:6.0.9-1.0.0 redis-cli -h redis ping
   ```

   Expected output is:
  
   ```text
   PONG
   ```

* Put some data into Redis

   ```bash
   docker run --rm --network redis_default abrarov/redis:6.0.9-1.0.0 redis-cli -h redis set foo bar
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
   docker run --rm --network redis_default abrarov/redis:6.0.9-1.0.0 redis-cli -h redis get foo
   ```

   Expected output is:
  
   ```text
   bar
   ```

* Stop immediately and remove

   ```bash
   docker-compose -p redis down -v -t 0
   ```
