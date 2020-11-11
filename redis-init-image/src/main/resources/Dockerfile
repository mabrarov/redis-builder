FROM abrarov/j2cli:@j2cli.version@-@project.version@

USER root

ADD ["rootfs.tar", "/"]

ENV PATH="@j2cli.venv.dir@/bin:${PATH}"

RUN ["/bin/busybox", "sh", "-c", "set -e && for cmd in $(/bin/busybox --list); do /bin/busybox ln -s /bin/busybox \"/usr/bin/${cmd}\"; done"]

USER nonroot

CMD ["/run.sh"]

ENV REDIS_CONFIG_FILE="/config/redis.conf" \
    REDIS_CONFIG_TEMPLATE_FILE="/redis.conf.j2" \
    REDIS_CONFIG_FILTERS_FILE="/filters.py" \
    REDIS_PORT="6379" \
    REDIS_PROTECTED_MODE="yes" \
    REDIS_LISTEN_BACKLOG="511" \
    REDIS_LOG_LEVEL="notice" \
    REDIS_SHOW_LOGO="yes" \
    REDIS_DATA_DIR="./" \
    REDIS_APPENDONLY="no"

LABEL name="@docker.repository@" \
    version="@project.version@" \
    release="@project.version@" \
    build-date="@git.commit.time@" \
    vcs-url="@git.remote.origin.url@" \
    vcs-type="git" \
    vcs-ref="@git.commit.id@"
