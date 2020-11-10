FROM gcr.io/distroless/cc-debian10

ADD ["redis-dist.tar.gz", "/usr/local"]

ADD ["rootfs.tar", "/"]

USER nonroot

WORKDIR /data

CMD ["redis-server", "--version"]

LABEL name="@docker.repository@" \
    version="@project.version@" \
    release="@project.version@" \
    build-date="@git.commit.time@" \
    vcs-url="@git.remote.origin.url@" \
    vcs-type="git" \
    vcs-ref="@git.commit.id@" \
    redis-version="@redis.version@"
