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

RUN venv_dir="@j2cli.venv.dir@" && \
    "${venv_dir}/bin/pip" install --disable-pip-version-check j2cli[yaml]=="@j2cli.version@" && \
    output_file="@output.file@" && \
    mkdir -p "$(dirname "${output_file}")" && \
    ls -A -1 "${venv_dir}" \
      | tar --sort=name --owner=root:0 --group=root:0 --mtime='UTC 1970-01-01' \
          -C "${venv_dir}" -czf "${output_file}" --verbatim-files-from -T - && \
    echo "Jinja binaries location: ${output_file}"

CMD ["/bin/cat", "@output.file@"]

LABEL name="@docker.repository@" \
    version="@project.version@" \
    release="@project.version@" \
    build-date="@git.commit.time@" \
    vcs-url="@git.remote.origin.url@" \
    vcs-type="git" \
    vcs-ref="@git.commit.id@" \
    j2cli-version="@j2cli.version@"
