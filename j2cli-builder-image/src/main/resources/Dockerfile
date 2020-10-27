FROM debian:10-slim

RUN apt-get update && \
    apt-get install -y --no-install-suggests --no-install-recommends \
      python3-venv \
      gcc \
      libpython3-dev && \
    venv_dir="@j2cli.venv.dir@" && \
    python3 -m venv "${venv_dir}" && \
    "${venv_dir}/bin/pip" install --upgrade pip && \
    rm -rf /var/lib/apt/lists/*

ADD ["rootfs.tar", "/"]

RUN venv_dir="@j2cli.venv.dir@" && \
    "${venv_dir}/bin/pip" install --disable-pip-version-check -r /usr/src/requirements.txt && \
    output_file="@output.file@" && \
    mkdir -p "$(dirname "${output_file}")" && \
    tar -C "$(dirname "${venv_dir}")" -czf "${output_file}" "$(basename "${venv_dir}")" && \
    echo "Jinja binaries location: @output.file@"

CMD ["/bin/cat", "@output.file@"]

LABEL name="@docker.repository@" \
    version="@project.version@" \
    release="@project.version@" \
    build-date="@git.commit.time@" \
    vcs-url="@git.remote.origin.url@" \
    vcs-type="git" \
    vcs-ref="@git.commit.id@"