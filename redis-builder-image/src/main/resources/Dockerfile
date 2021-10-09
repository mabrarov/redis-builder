FROM debian:11-slim

ENV TZ="Europe/Moscow"

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
    gnu_arch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" && \
    extra_jemalloc_configure_flags="--build=${gnu_arch}" && \
    dpkg_arch="$(dpkg --print-architecture)" && \
    case "${dpkg_arch##*-}" in \
      amd64 | i386 | x32) extra_jemalloc_configure_flags="${extra_jemalloc_configure_flags} --with-lg-page=12" ;; \
      *) extra_jemalloc_configure_flags="${extra_jemalloc_configure_flags} --with-lg-page=16" ;; \
    esac && \
    extra_jemalloc_configure_flags="${extra_jemalloc_configure_flags} --with-lg-hugepage=21" && \
    jemalloc_configure_cmd="cd jemalloc && ./configure " && \
    deps_makefile="${source_dir}/deps/Makefile" && \
    grep -F -- "${jemalloc_configure_cmd}" "${deps_makefile}" && \
    sed -ri 's!'"${jemalloc_configure_cmd}"'!&'"${extra_jemalloc_configure_flags}"' !' "${deps_makefile}" && \
    grep -F -- "${jemalloc_configure_cmd}${extra_jemalloc_configure_flags} " "${deps_makefile}" && \
    make -C "${source_dir}" BUILD_TLS=yes all && \
    install_dir="$(mktemp -d)" && \
    make -C "${source_dir}" PREFIX="${install_dir}" install && \
    output_file="@output.file@" && \
    mkdir -p "$(dirname "${output_file}")" && \
    ls -A -1 "${install_dir}" \
      | tar --sort=name --owner=root:0 --group=root:0 --mtime='UTC 1970-01-01' \
          -C "${install_dir}" -czf "${output_file}" --verbatim-files-from -T - && \
    rm -rf "${install_dir}" && \
    make -C "${source_dir}" distclean && \
    echo "Redis binaries location: ${output_file}"

CMD ["/bin/cat", "@output.file@"]

LABEL name="@docker.repository@" \
    version="@project.version@" \
    release="@project.version@" \
    build-date="@git.commit.time@" \
    vcs-url="@git.remote.origin.url@" \
    vcs-type="git" \
    vcs-ref="@git.commit.id@" \
    redis-version="@redis.version@"
