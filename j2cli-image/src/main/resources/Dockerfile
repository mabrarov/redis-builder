FROM gcr.io/distroless/python3-debian11

ADD ["j2cli.tar.gz", "@j2cli.venv.dir@"]

USER nonroot

ENTRYPOINT []

CMD ["@j2cli.venv.dir@/bin/j2", "--version"]

LABEL name="@docker.repository@" \
    version="@project.version@" \
    release="@project.version@" \
    build-date="@git.commit.time@" \
    vcs-url="@git.remote.origin.url@" \
    vcs-type="git" \
    vcs-ref="@git.commit.id@" \
    j2cli-version="@j2cli.version@"
