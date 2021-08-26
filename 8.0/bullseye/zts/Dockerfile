#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM debian:bullseye-slim

# prevent Debian's PHP packages from being installed
# https://github.com/docker-library/php/pull/542
RUN set -eux; \
    { \
    echo 'Package: php*'; \
    echo 'Pin: release *'; \
    echo 'Pin-Priority: -1'; \
    } > /etc/apt/preferences.d/no-debian-php

# dependencies required for running "phpize"
# (see persistent deps below)
ENV PHPIZE_DEPS \
    autoconf \
    dpkg-dev \
    file \
    g++ \
    gcc \
    libc-dev \
    make \
    pkg-config \
    re2c

COPY sources.list /etc/apt/

# persistent / runtime deps
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
    $PHPIZE_DEPS \
    ca-certificates \
    curl \
    xz-utils \
    ; \
    rm -rf /var/lib/apt/lists/*

ENV PHP_INI_DIR /usr/local/etc/php
RUN set -eux; \
    mkdir -p "$PHP_INI_DIR/conf.d"; \
    # allow running as an arbitrary user (https://github.com/docker-library/php/issues/743)
    [ ! -d /app-src ]; \
    mkdir -p /app-src; \
    chown www-data:www-data /app-src; \
    chmod 777 /app-src

ENV PHP_EXTRA_CONFIGURE_ARGS --enable-zts --disable-cgi

# Apply stack smash protection to functions using local buffers and alloca()
# Make PHP's main executable position-independent (improves ASLR security mechanism, and has no performance impact on x86_64)
# Enable optimization (-O2)
# Enable linker optimization (this sorts the hash buckets to improve cache locality, and is non-default)
# https://github.com/docker-library/php/issues/272
# -D_LARGEFILE_SOURCE and -D_FILE_OFFSET_BITS=64 (https://www.php.net/manual/en/intro.filesystem.php)
ENV PHP_CFLAGS="-fstack-protector-strong -fpic -fpie -O2 -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64"
ENV PHP_CPPFLAGS="$PHP_CFLAGS"
ENV PHP_LDFLAGS="-Wl,-O1 -pie"

ENV GPG_KEYS 1729F83938DA44E27BA0F4D3DBDB397470D12172 BFDDD28642824F8118EF77909B67A5C12229118F

ENV PHP_VERSION 8.0.9
ENV PHP_URL="https://www.php.net/distributions/php-8.0.9.tar.xz" PHP_ASC_URL="https://www.php.net/distributions/php-8.0.9.tar.xz.asc"
ENV PHP_SHA256="71a01b2b56544e20e28696ad5b366e431a0984eaa39aa5e35426a4843e172010"
ENV APP_ROOT=/app-src \
    PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin:${APP_ROOT}:${APP_ROOT}/bin

RUN set -eux; \
    \
    savedAptMark="$(apt-mark showmanual)"; \
    apt install apt-transport-https ca-certificates; \
    apt-get update; \
    apt-get install -y --no-install-recommends gnupg dirmngr; \
    rm -rf /var/lib/apt/lists/*; \
    \
    mkdir -p /usr/src; \
    cd /usr/src; \
    \
    curl -fsSL -o php.tar.xz "$PHP_URL"; \
    \
    if [ -n "$PHP_SHA256" ]; then \
    echo "$PHP_SHA256 *php.tar.xz" | sha256sum -c -; \
    fi; \
    \
    if [ -n "$PHP_ASC_URL" ]; then \
    curl -fsSL -o php.tar.xz.asc "$PHP_ASC_URL"; \
    export GNUPGHOME="$(mktemp -d)"; \
    for key in $GPG_KEYS; do \
    gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key"; \
    done; \
    gpg --batch --verify php.tar.xz.asc php.tar.xz; \
    gpgconf --kill all; \
    rm -rf "$GNUPGHOME"; \
    fi; \
    \
    apt-mark auto '.*' > /dev/null; \
    apt-mark manual $savedAptMark > /dev/null; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false

COPY docker-php-source /usr/local/bin/

RUN set -eux; \
    \
    savedAptMark="$(apt-mark showmanual)"; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
    libargon2-dev \
    libcurl4-openssl-dev \
    libedit-dev \
    libonig-dev \
    libsodium-dev \
    libsqlite3-dev \
    libssl-dev \
    libxml2-dev \
    zlib1g-dev \
    libpcre3 \
    libpcre3-dev \
    openssl \
    mysql-common \
    libmysql++-dev \
    ${PHP_EXTRA_BUILD_DEPS:-} \
    ; \
    rm -rf /var/lib/apt/lists/*; \
    \
    export \
    CFLAGS="$PHP_CFLAGS" \
    CPPFLAGS="$PHP_CPPFLAGS" \
    LDFLAGS="$PHP_LDFLAGS" \
    ; \
    docker-php-source extract; \
    which mysql_config; \
    cd /usr/src/php; \
    gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"; \
    debMultiarch="$(dpkg-architecture --query DEB_BUILD_MULTIARCH)"; \
    # https://bugs.php.net/bug.php?id=74125
    if [ ! -d /usr/include/curl ]; then \
    ln -sT "/usr/include/$debMultiarch/curl" /usr/local/include/curl; \
    fi; \
    ./configure \
    --build="$gnuArch" \
    --with-config-file-path="$PHP_INI_DIR" \
    --with-config-file-scan-dir="$PHP_INI_DIR/conf.d" \
    \
    --enable-cli \
    --enable-embed=shared \
    # make sure invalid --configure-flags are fatal errors instead of just warnings
    --enable-option-checking=fatal \
    \
    # https://github.com/docker-library/php/issues/439
    --with-mhash \
    \
    # https://github.com/docker-library/php/issues/822
    --with-pic \
    \
    # --enable-ftp is included here because ftp_ssl_connect() needs ftp to be compiled statically (see https://github.com/docker-library/php/issues/236)
    --enable-ftp \
    # --enable-mbstring is included here because otherwise there's no way to get pecl to use it properly (see https://github.com/docker-library/php/issues/195)
    --enable-mbstring \
    # --enable-mysqlnd is included here because it's harder to compile after the fact than extensions are (since it's a plugin for several extensions, not an extension in itself)
    --enable-mysqlnd \
    --with-pdo-mysql=/usr/bin/mysql_config \
    --with-mysqli=/usr/bin/mysql_config \
    # https://wiki.php.net/rfc/argon2_password_hash (7.2+)
    --with-password-argon2 \
    # https://wiki.php.net/rfc/libsodium
    --with-sodium=shared \
    --with-pcre-jit \
    # always build against system sqlite3 (https://github.com/php/php-src/commit/6083a387a81dbbd66d6316a3a12a63f06d5f7109)
    --with-curl \
    --with-libedit \
    --with-openssl \
    --enable-pcntl \
    --with-zlib \
    \
    # in PHP 7.4+, the pecl/pear installers are officially deprecated (requiring an explicit "--with-pear")
    --with-pear \
    \
    # bundled pcre does not support JIT on s390x
    # https://manpages.debian.org/bullseye/libpcre3-dev/pcrejit.3.en.html#AVAILABILITY_OF_JIT_SUPPORT
    $(test "$gnuArch" = 's390x-linux-gnu' && echo '--without-pcre-jit') \
    --with-libdir="lib/$debMultiarch" \
    \
    ${PHP_EXTRA_CONFIGURE_ARGS:-} \
    ; \
    make -j "$(nproc)"; \
    find -type f -name '*.a' -delete; \
    make install; \
    find /usr/local/bin /usr/local/sbin -type f -executable -exec strip --strip-all '{}' + || true; \
    make clean; \
    \
    # https://github.com/docker-library/php/issues/692 (copy default example "php.ini" files somewhere easily discoverable)
    cp -v php.ini-* "$PHP_INI_DIR/"; \
    cp -v php.ini-production "$PHP_INI_DIR/php.ini"; \
    \
    cd /; \
    docker-php-source delete; \
    \
    # reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
    apt-mark auto '.*' > /dev/null; \
    [ -z "$savedAptMark" ] || apt-mark manual $savedAptMark; \
    find /usr/local -type f -executable -exec ldd '{}' ';' \
    | awk '/=>/ { print $(NF-1) }' \
    | sort -u \
    | xargs -r dpkg-query --search \
    | cut -d: -f1 \
    | sort -u \
    | xargs -r apt-mark manual \
    ; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    \
    # update pecl channel definitions https://github.com/docker-library/php/issues/443
    pecl update-channels; \
    pecl install redis ; \
    pecl install swoole ; \
    rm -rf /tmp/pear ~/.pearrc; \
    \
    # smoke test
    php --version

COPY docker-php-ext-* docker-php-entrypoint /usr/local/bin/
RUN set -eux; \
    apt-get update  -y; \
    apt-get install libpcre3 libpcre3-dev openssl libssl-dev ncat -y; \
    rm -rf /var/lib/apt/lists/*
# sodium was built as a shared module (so that it can be replaced later if so desired), so let's enable it too (https://github.com/docker-library/php/issues/598)
RUN set -eux; \
    docker-php-ext-enable sodium ; \
    docker-php-ext-enable redis ;\
    docker-php-ext-enable swoole ;\
    sed -i "s@max_execution_time = 30@max_execution_time = 300@g" "$PHP_INI_DIR/php.ini" && \
    sed -i "s@post_max_size = 8M@post_max_size = 32M@g" "$PHP_INI_DIR/php.ini" && \
    sed -i "s@max_input_time = 60@max_input_time = 600@g" "$PHP_INI_DIR/php.ini" && \
    sed -i "s@memory_limit = 128M@memory_limit = 2048M@g" "$PHP_INI_DIR/php.ini"&& \
    # php --ini
    sed -i "2i swoole.use_shortname=off\nswoole.unixsock_buffer_size=32M" "$PHP_INI_DIR/conf.d/docker-php-ext-swoole.ini"
# nc -z www.baidu.com 80
EXPOSE 8080 \
    8443 \
    9443 \
    9501
WORKDIR ${APP_ROOT}
ENTRYPOINT ["docker-php-entrypoint"]
CMD ["php", "-a"]
