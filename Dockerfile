ARG VERSION=4_7_0-23-01-2026-1
ARG UID=200020
ARG GID=200020
ARG PHP=php84

FROM alpine

ARG VERSION
ARG UID
ARG GID
ARG PHP

LABEL maintainer="Thien Tran contact@tommytran.io"

#Install dependencies and fix issue in apache
RUN apk -U upgrade \
    && apk add ca-certificates composer curl git libstdc++ nginx supervisor \
        ${PHP}-fpm \
        ${PHP}-cli \
        ${PHP}-curl \
        ${PHP}-ldap \
        ${PHP}-bcmath \
        ${PHP}-mbstring \
        ${PHP}-zip \
        ${PHP}-xml \
        ${PHP}-pecl-apcu

    && apk add --virtual .build-deps \
        build-base pkgconf \
        ${PHP}-dev \
        ${PHP}-pear

    && rm -rf /var/cache/apk/* \
    && pecl install mongodb
#    && echo "extension=mongodb.so" >> /etc/${PHP}/fpm/php.ini && \
#    && echo "extension=mongodb.so" >> /etc/${PHP}/cli/php.ini && \

# Configure PHP (combine all sed commands)
# RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/${PHP}/fpm/php.ini && \
#    sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/${PHP}/cli/php.ini && \
#    sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/${PHP}/fpm/php-fpm.conf && \
#    sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/${PHP}/fpm/php.ini && \
#    sed -i -e "s/memory_limit\s*=\s*128M/memory_limit = 512M/g" /etc/${PHP}/fpm/php.ini && \
#    sed -i "s/max_execution_time = 30/max_execution_time = 120/" /etc/${PHP}/fpm/php.ini && \
#    sed -i "s/;listen.owner = www-data/listen.owner = www-data/" /etc/${PHP}/fpm/pool.d/www.conf && \
#    sed -i "s/;listen.group = www-data/listen.group = www-data/" /etc/${PHP}/fpm/pool.d/www.conf && \
#    sed -i "s/;listen.mode = 0660/listen.mode = 0660/" /etc/${PHP}/fpm/pool.d/www.conf && \
#    sed -i "s|^listen = .*|listen = /var/run/php/php-fpm.sock|" /etc/${PHP}/fpm/pool.d/www.conf && \
#    sed -i "s/;listen.backlog = 511/listen.backlog = 4096/" /etc/${PHP}/fpm/pool.d/www.conf && \
#    sed -i "s/pm.max_children = 5/pm.max_children = 96/" /etc/${PHP}/fpm/pool.d/www.conf && \
#    sed -i "s/pm.start_servers = 2/pm.start_servers = 8/" /etc/${PHP}/fpm/pool.d/www.conf && \
#    sed -i "s/pm.max_spare_servers = 3/pm.max_spare_servers = 16/" /etc/${PHP}/fpm/pool.d/www.conf && \
#    sed -i "s/;clear_env = no/clear_env = no/" /etc/${PHP}/fpm/pool.d/www.conf && \
#    sed -i "s/;request_terminate_timeout = 0/request_terminate_timeout = 0/" /etc/${PHP}/fpm/pool.d/www.conf && \
#    # Logs configuration
#    sed -i "s/error_log = \/var\/log\/php${PHPVERSION}-fpm.log/error_log = \/proc\/self\/fd\/2/" /etc/${PHP}/fpm/php-fpm.conf && \
#    sed -i "s/;catch_workers_output = yes/catch_workers_output = yes/" /etc/${PHP}/fpm/pool.d/www.conf
