FROM debian:10-slim

RUN apt-get update && \
    apt-get install -y --no-install-suggests --no-install-recommends \
      dpkg-dev \
      gcc \
      libc6-dev \
      libssl-dev \
      make && \
    rm -rf /var/lib/apt/lists/*

ADD ["redis.tar.gz", "/usr/src"]

RUN source_dir="/usr/src/redis-@redis.version@" && \
    make -C "${source_dir}" BUILD_TLS=yes all && \
    install_dir="$(mktemp -d)" && \
    make -C "${source_dir}" PREFIX="${install_dir}" install && \
    output_file="@output.file@" && \
    mkdir -p "$(dirname "${output_file}")" && \
    ls -A -1 "${install_dir}" \
      | tar -C "${install_dir}" -czf "${output_file}" --verbatim-files-from -T - && \
    rm -rf "${install_dir}" && \
    make -C "${source_dir}" distclean && \
    echo "Redis binaries location: @output.file@"

CMD ["/bin/cat", "@output.file@"]

LABEL name="@docker.repository@" \
    version="@project.version@" \
    release="@project.version@" \
    build-date="@git.commit.time@" \
    vcs-url="@git.remote.origin.url@" \
    vcs-type="git" \
    vcs-ref="@git.commit.id@" \
    redis-version="@redis.version@"
