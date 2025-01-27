FROM littleof/php-nts:8

# 初始化镜像
# RUN rpmkeys --import file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial && \
#     INSTALL_PKGS="bsdtar \
#     findutils \
#     gettext \
#     groff-base \
#     glibc-locale-source \
#     glibc-langpack-en \
#     rsync \
#     scl-utils \
#     tar \
#     unzip \
#     xz \
#     yum \
#     yum-utils \
#     autoconf \
#     automake \
#     bzip2 \
#     gcc \
#     gcc-c++ \
#     gd-devel \
#     gdb \
#     git \
#     libcurl-devel \
#     libpq-devel \
#     libxml2-devel \
#     libxslt-devel \
#     lsof \
#     make \
#     openssl-devel \
#     patch \
#     procps-ng \
#     redhat-rpm-config \
#     unzip \
#     wget \
#     which \
#     openssl \
#     mysql-devel \
#     zlib-devel" && \
#     mkdir -p "${HOME}"/.pki/nssdb && \
#     chown -R 1001:0 "${HOME}"/.pki && \
#     yum install -y $INSTALL_PKGS --setopt=tsflags=nodocs --nogpgcheck && \
#     rm -rf /var/cache/yum/* && \
#     yum repolist && \
#     yum -y clean all --enablerepo='*' && \
#     dnf install dnf-utils http://rpms.remirepo.net/enterprise/remi-release-8.rpm -y && \
#     yum -y upgrade --setopt=tsflags=nodocs --nogpgcheck && \
#     rm -rf /var/cache/yum/* && \
#     yum repolist && \
#     yum -y clean all --enablerepo='*'

#此镜像提供了一个PHP环境，可用于运行PHP 应用程序。
EXPOSE 8080 \
    8443 \
    9443 \
    9501

ENV NAME=php \
    APP_ROOT=/app-src \
    PHP_VERSION=8.0 \
    UNIT_VERSION=1.24.0 \
    PHP_VER_SHORT=80 \
    PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin:${APP_ROOT}:${APP_ROOT}/bin \
    SUMMARY="Platform for building and running PHP ${PHP_VERSION} applications" \
    DESCRIPTION="PHP ${PHP_VERSION} UNTI available as container is a base platform for \
    building and running various PHP ${PHP_VERSION} applications and frameworks. \
    PHP is an HTML-embedded scripting language. PHP attempts to make it easy for developers \
    to write dynamically generated web pages. PHP also offers built-in database integration \
    for several commercial and non-commercial database management systems, so writing \
    a database-enabled webpage with PHP is fairly simple. The most common use of PHP coding \
    is probably as a replacement for CGI scripts."

LABEL summary="$SUMMARY" \
    name="littleof/${NAME}-${PHP_VER_SHORT}-unit" \
    version="${PHP_VERSION}" \
    help="For more information visit https://github.com/littlezo/s2i-php-container.git" \
    usage="s2i build https://github.com/littlezo/s2i-php-container.git littleof/${NAME}-${PHP_VER_SHORT}-centos8-unit sample-server" \
    maintainer="@小小只^v^ <littlezov@qq.com>" \
    description="$DESCRIPTION" \
    com.xjoycloud.description="$DESCRIPTION" \
    com.xjoycloud.display-name="PHP ${PHP_VERSION} unit" \
    com.xjoycloud.expose-services="8080:http" \
    com.xjoycloud.expose-services="8443:https" \
    com.xjoycloud.tcp.expose-services="9501:tcp" \
    com.xjoycloud.socket.expose-services="9443:websocket" \
    com.xjoycloud.tags="builder,${NAME},${NAME}-${PHP_VERSION},unit,${NAME}-unit" \
    com.xjoycloud.dev-mode="${DEV_MODE}:false" \
    com.xjoycloud.deployments-dir="${APP_ROOT}" \
    com.label-schema.maintainer-url="https://github.com/littlezo" \
    com.xjoycloud.image.title="CentOS Base or PHP and Unit Image " \
    com.xjoycloud.image.license="GPL v2.0" \
    com.xjoycloud.image.created="${BUILD_DATE}"
# 项目目录
WORKDIR ${APP_ROOT}
# 更换源
# RUN ls  /etc/yum.repos.d/ && curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-8.repo && cat /etc/yum.repos.d/CentOS-Base.repo && yum install -y epel-release
# 安装 环境
# RUN dnf module reset php && \
#     dnf module enable php:remi-${PHP_VERSION} -y && \
#     dnf install pkgconfig -y && \
#     INSTALL_PKGS="php-gd php-xhprof php-ast php-cli php-dba php-dbg php-pdo \
#     php-xml php-imap php-intl php-json php-ldap php-snmp php-soap \
#     php-tidy php-devel php-bcmath php-brotli php-common php-recode \
#     php-sodium php-xmlrpc php-enchant php-libvirt php-mysqlnd \
#     php-pecl-ds php-pecl-ev php-process php-embedded php-mbstring \
#     php-pecl-dio php-pecl-eio php-pecl-env php-pecl-lzf php-pecl-nsq \
#     php-pecl-psr php-pecl-zip php-pecl-zmq php-componere php-pecl-grpc \
#     php-pecl-http php-pecl-ssh2 php-pecl-sync php-pecl-uuid \
#     php-pecl-vips php-pecl-yaml php-phpiredis php-wkhtmltox \
#     php-pecl-event php-pecl-geoip php-pecl-gnupg php-pecl-mysql \
#     php-pecl-oauth php-pecl-stats php-pecl-xattr php-pecl-xxtea \
#     php-pecl-base58 php-pecl-hrtime php-pecl-mcrypt php-pecl-pdflib \
#     php-pecl-propro php-pecl-redis php-pecl-decimal php-pecl-xmldiff \
#     php-pecl-igbinary php-pecl-mogilefs php-pecl-json-post \
#     php-pecl-ip2location php-pecl-http-message php-gmp php-pecl-apcu \
#     php-zip php-swoole php-pear php-pthreads" && \
#     yum install -y libstdc++ openssl pcre-devel pcre2-devel openssl-devel supervisor \
#     $INSTALL_PKGS --skip-broken --setopt=tsflags=nodocs --nogpgcheck && \
#     rm -rf /var/cache/yum/* && \
#     yum repolist && \
#     yum -y clean all --enablerepo='*' && \
#     pecl install pthreads && \
#     wget -O /usr/local/bin/composer https://mirrors.aliyun.com/composer/composer.phar && \
#     chmod a+x /usr/local/bin/composer && \
#     composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/ && \
#      sed -i "s@;date.timezone =@date.timezone = Asia/Shanghai@g" /etc/php.ini && \
#     sed -i "s@max_execution_time = 30@max_execution_time = 300@g" /etc/php.ini && \
#     sed -i "s@post_max_size = 8M@post_max_size = 32M@g" /etc/php.ini && \
#     sed -i "s@max_input_time = 60@max_input_time = 600@g" /etc/php.ini && \
#     sed -i "s@memory_limit = 128M@memory_limit = 2048M@g" /etc/php.ini && \
#     sed -i "2i swoole.use_shortname=off\nswoole.unixsock_buffer_size=32M" /etc/php.d/40-swoole.ini
# RUN cat /etc/os-release
# RUN cat /etc/apt/sources.list
# COPY sources.list /etc/apt/
# RUN cat /etc/apt/sources.list
RUN set -eux; \
    apt-get update  -y; \
    apt-get install libpcre3 libpcre3-dev openssl libssl-dev -y; \
    rm -rf /var/lib/apt/lists/* ;\
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false

COPY entrypoint.sh /usr/local/bin/
RUN curl -O https://unit.nginx.org/download/unit-"${UNIT_VERSION}".tar.gz && \
    tar xzf unit-${UNIT_VERSION}.tar.gz && \
    rm -rf unit-${UNIT_VERSION}.tar.gz && \
    cd unit-${UNIT_VERSION} && \
    ./configure --prefix=/usr \
    --state=/var/lib/unit \
    --control=unix:/var/run/control.unit.sock \
    --pid=/var/run/unit.pid \
    --log=/var/log/unit.log \
    --tmp=/var/tmp \
    --user=unit \
    --group=unit \
    --openssl \
    --modules=/usr/lib/unit/modules && \
    make && \
    make install && \
    ./configure php \
    --module=php \
    --config=/usr/local/bin/php-config \
    --lib-path=/usr/lib64/ && \
    make && \
    make install && \
    make clean && \
    rm -rf ../unit-${UNIT_VERSION} && \
    set -x && \
    groupadd unit && \
    useradd unit -g unit -s /sbin/nologin -M && \
    mkdir -p /usr/lib/unit/modules && \
    mkdir -p /usr/lib/unit/debug-modules && \
    php -v && \
    chmod +x /usr/local/bin/entrypoint.sh && \
    unitd --version && \
    mkdir -p /var/lib/unit/ && \
    mkdir -p /entrypoint.d/ && \
    chmod +x /usr/local/bin/entrypoint.sh && \
    cd ${APP_ROOT}
COPY ./entrypoint.d /entrypoint.d
STOPSIGNAL SIGQUIT
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["unitd", "--no-daemon", "--control", "127.0.0.1:8233"]
