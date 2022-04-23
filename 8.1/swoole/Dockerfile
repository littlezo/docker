FROM php:8.0.15-cli

ARG timezone
#此镜像提供了一个PHP环境，可用于运行PHP 应用程序。
EXPOSE 8443 \
    9443 \
    9500
# 设置镜像信息
ENV NAME=php \
    APP_ROOT=/app-src \
    PHP_VERSION=8.1.1 \
    PHP_VER_SHORT=81 \
    RUNTIME=swoole \
    TIMEZONE=${timezone:-"Asia/Shanghai"} \
    APP_ENV=prod \
    SCAN_CACHEABLE=(true) \
    PHP_INI_DIR=/usr/local/etc/php \
    PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin:${APP_ROOT}:${APP_ROOT}/bin \
    SUMMARY="用于构建和运行 PHP ${PHP_VERSION} ${RUNTIME} 应用程序的平台" \
    DESCRIPTION="PHP ${PHP_VERSION} 作为容器提供是构建和运行各种 PHP ${PHP_VERSION} ${RUNTIME}应用程序和框架 "

LABEL summary="$SUMMARY" \
    name="littleof/${NAME}-${RUNTIME}" \
    version="${PHP_VERSION}" \
    help="For more information visit https://github.com/littlezo/s2i-php-container.git" \
    usage="s2i build https://github.com/littlezo/s2i-php-container.git littleof/${NAME}-${RUNTIME} sample-server" \
    maintainer="@小小只^v^ <littlezov@qq.com>" \
    description="$DESCRIPTION" \
    com.xjoycloud.description="$DESCRIPTION" \
    com.xjoycloud.display-name="PHP ${PHP_VERSION} ${RUNTIME}" \
    com.xjoycloud.expose-services="8443:https" \
    com.xjoycloud.socket.expose-services="9443:websocket" \
    com.xjoycloud.tcp.expose-services="9500:tcp" \
    com.xjoycloud.tags="builder,${NAME},${NAME}-${PHP_VERSION},${RUNTIME},${NAME}-${RUNTIME}" \
    com.xjoycloud.dev-mode="${DEV_MODE}:false" \
    com.xjoycloud.deployments-dir="${APP_ROOT}" \
    com.label-schema.maintainer-url="https://github.com/littlezo" \
    com.xjoycloud.image.title="Debian Bullseye or ${NAME} and ${RUNTIME} Image " \
    com.xjoycloud.image.license="MIT v2.0" \
    com.xjoycloud.image.created="${BUILD_DATE}"
# 项目目录
WORKDIR ${APP_ROOT}

# 初始化镜像
COPY /repos/sources.list /etc/apt/

RUN set -eux; \
    # sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories; \
    mkdir -p ${APP_ROOT}; \
    mkdir -p /entrypoint.d; \
    apt-get update  -y
# COPY /entrypoint.d/entrypoint.sh /usr/local/bin/
# COPY /entrypoint.d /entrypoint.d


# 安装 环境
RUN set -eux; \
    cp -v "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"; \
    apt-get install libpcre3 wget libpcre3-dev openssl libssl-dev -y; \
    rm -rf /var/lib/apt/lists/* ;\
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false ;\
    \
    pecl update-channels; \
    pecl install redis ; \
    pecl install swoole ; \
    rm -rf /tmp/pear ~/.pearrc; \
    \
    docker-php-ext-enable sockets ;\
    docker-php-ext-enable sodium ;\
    docker-php-ext-enable redis ;\
    docker-php-ext-enable swoole ;\
    wget -O /usr/local/bin/composer https://mirrors.aliyun.com/composer/composer.phar ;\
    chmod a+x /usr/local/bin/composer ;\
    composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/ ;\
    \
    ls "$PHP_INI_DIR" ;\
    ls "$PHP_INI_DIR/conf.d/" ;\
    sed -i "s@;date.timezone =@date.timezone = Asia/Shanghai@g" "$PHP_INI_DIR/php.ini" ;\
    sed -i "s@max_execution_time = 30@max_execution_time = 300@g" "$PHP_INI_DIR/php.ini" ;\
    sed -i "s@post_max_size = 8M@post_max_size = 32M@g" "$PHP_INI_DIR/php.ini" ;\
    sed -i "s@max_input_time = 60@max_input_time = 600@g" "$PHP_INI_DIR/php.ini" ;\
    sed -i "s@memory_limit = 128M@memory_limit = 2048M@g" "$PHP_INI_DIR/php.ini" ;\
    sed -i "s@upload_max_filesize = 2MM@upload_max_filesize = 2048M@g" "$PHP_INI_DIR/php.ini" ;\
    sed -i "s@max_file_uploads = 20@max_file_uploads = 64@g" "$PHP_INI_DIR/php.ini" ;\
    { \
    echo "$PHP_INI_DIR/conf.d/docker-php-ext-swoole.ini"; \
    echo "swoole.use_shortname=off"; \
    echo "swoole.unixsock_buffer_size=32M"; \
    } | tee >>"$PHP_INI_DIR/conf.d/docker-php-ext-swoole.ini" \
    \
    chmod +x /usr/local/bin/entrypoint.sh ;\
    ls $PHP_INI_DIR ;\
    ls $PHP_INI_DIR/conf.d/ ;\
    php --ini ;\
    php -m ;\
    php --ri redis ;\
    php --ri swoole ;\
    \
    cat "$PHP_INI_DIR/conf.d/docker-php-ext-swoole.ini" ;\
    ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime ;\
    echo "${TIMEZONE}" > /etc/timezone ;\
    cd ${APP_ROOT}

STOPSIGNAL SIGQUIT
# ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["php", "-a"]
