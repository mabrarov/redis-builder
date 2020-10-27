FROM abrarov/j2cli:@j2cli.version@-@project.version@

ADD ["rootfs.tar", "/"]

RUN ["/bin/busybox", "sh", "-c", "set -e && for cmd in $(/bin/busybox --list); do /bin/busybox ln -s /bin/busybox \"/usr/bin/${cmd}\"; done"]

CMD ["/run.sh"]

ENV REDIS_PROTECTED_MODE="no" \
    REDIS_LISTEN_BACKLOG="511" \
    REDIS_LOG_LEVEL="notice" \
    REDIS_SHOW_LOGO="yes"

LABEL name="@docker.repository@" \
    version="@project.version@" \
    release="@project.version@" \
    build-date="@git.commit.time@" \
    vcs-url="@git.remote.origin.url@" \
    vcs-type="git" \
    vcs-ref="@git.commit.id@"