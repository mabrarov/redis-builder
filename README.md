# Redis Docker Image Builder

Builder of Docker image with [Redis](https://github.com/redis/redis) using
["Distroless" Docker Image](https://github.com/GoogleContainerTools/distroless) as a base image.

## Building

### Building Requirements

1. JDK 1.8+
1. Docker 1.12+
1. If remote Docker instance is used then `DOCKER_HOST` environment variable should point to that
   engine and include the schema, like `tcp://docker-host:2375` instead of `docker-host:2375`.
1. The current directory is directory where this repository is cloned.
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

1. Version

   ```bash
   docker run --rm abrarov/redis:6.0.8-0.0.1
   ```

   Expected output is:

   ```text
   Redis server v=6.0.8 sha=00000000:0 malloc=libc bits=64 build=89228db3570a88e7
   ```

1. Redis CLI

   ```bash
   container_id="$(docker run -d abrarov/redis:6.0.8-0.0.1 redis-server)" && \
   docker exec -it "${container_id}" redis-cli ping && \
   docker rm -fv "${container_id}" > /dev/null
   ```

   Expected output is:

   ```text
   PONG
   ```
