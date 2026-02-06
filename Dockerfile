ARG VERSION=4_7_0-23-01-2026-1
ARG UID=200020
ARG GID=200020
ARG PHP=php84

FROM linagora/esn-sabre:sabre-${VERSION} AS extract

FROM alpine

ARG VERSION
ARG UID
ARG GID
ARG PHP

LABEL maintainer="Thien Tran contact@tommytran.io"

#Install dependencies and fix issue in apache
RUN apk -U upgrade \
    && apk add ca-certificates composer curl git libstdc++ nginx sed supervisor \
        ${PHP}-fpm \
        ${PHP}-cli \
        ${PHP}-curl \
        ${PHP}-ldap \
        ${PHP}-bcmath \
        ${PHP}-mbstring \
        ${PHP}-zip \
        ${PHP}-xml \
        ${PHP}-pecl-apcu \
        ${PHP}-pecl-mongodb \
        ${PHP}-sockets \
        ${PHP}-ctype \
        ${PHP}-dom \
        ${PHP}-simplexml \
        ${PHP}-xmlreader \
        ${PHP}-xmlwriter \
    && apk add --virtual .build-deps \
        build-base pkgconf \
        ${PHP}-dev \
        ${PHP}-pear \
    && rm -rf /var/cache/apk/*

# Configure PHP (combine all sed commands)
RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/${PHP}/php.ini \
    && sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/${PHP}/php-fpm.conf
#    && sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/${PHP}/php.ini \
#    && sed -i -e "s/memory_limit\s*=\s*128M/memory_limit = 512M/g" /etc/${PHP}/php.ini \
#    && sed -i "s/max_execution_time = 30/max_execution_time = 120/" /etc/${PHP}/php.ini \
#    && sed -i "s/;listen.owner = nobody/listen.owner = nginx/" /etc/${PHP}/php-fpm.d/www.conf \
#    && sed -i "s/;listen.group = nobody/listen.group = nginx" /etc/${PHP}/php-fpm.d/www.conf \
#    && sed -i "s/;listen.mode = 0660/listen.mode = 0660/" /etc/${PHP}/php-fpm.d/www.conf
#    && sed -i "s|^listen = .*|listen = /var/run/php/php-fpm.sock|" /etc/${PHP}/php-fpm.d/www.conf \
#    && sed -i "s/;listen.backlog = 511/listen.backlog = 4096/" /etc/${PHP}/php-fpm.d/www.conf \
#    && sed -i "s/pm.max_children = 5/pm.max_children = 96/" /etc/${PHP}/php-fpm.d/www.conf \
#    && sed -i "s/pm.start_servers = 2/pm.start_servers = 8/" /etc/${PHP}/php-fpm.d/www.conf \
#    && sed -i "s/pm.max_spare_servers = 3/pm.max_spare_servers = 16/" /etc/${PHP}/php-fpm.d/www.conf \
#    && sed -i "s/;clear_env = no/clear_env = no/" /etc/${PHP}/php-fpm.d/www.conf \
#    && sed -i "s/;request_terminate_timeout = 0/request_terminate_timeout = 0/" /etc/${PHP}/php-fpm.d/www.conf
    # Logs configuration
#    && sed -i "s/error_log = \/var\/log\/php${PHPVERSION}-fpm.log/error_log = \/proc\/self\/fd\/2/" /etc/${PHP}/php-fpm.conf \
#    && sed -i "s/;catch_workers_output = yes/catch_workers_output = yes/" /etc/${PHP}/php-fpm.d/www.conf

COPY --from=extract /var/www /var/www

WORKDIR /var/www

# Install dependencies without dev packages (using install to respect composer.lock)
RUN git config --global --add safe.directory '/var/www/vendor/sabre/vobject' && \
    composer clearcache && \
    composer install --no-dev --optimize-autoloader --apcu-autoloader --no-interaction && \
    # Clean up composer cache and remove git
    rm -rf /root/.composer/cache && \
    apk del git

# Configure application
COPY nginx.conf /etc/nginx/nginx.conf

RUN sed -i 's#/etc/nginx/sites-enabled/default#/etc/nginx/http.d/default.conf#' docker/prepare/set_nginx_htpasswd.sh \
    && cp docker/prepare/set_nginx_htpasswd.sh /root/set_nginx_htpasswd.sh \
    && cp docker/config/default.conf /etc/nginx/http.d/default.conf \
    && cp docker/supervisord.conf /etc/supervisord.conf \
    && rm -rf localhost \
    && chown -R nginx:nginx /var/www \
    && chmod u+x /root/set_nginx_htpasswd.sh \
    && /root/set_nginx_htpasswd.sh \
    && mkdir -p /var/run/php

EXPOSE 80

CMD ["sh", "./scripts/start.sh"]
