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
    && apk add ca-certificates composer curl git libstdc++ nginx supervisor \
        ${PHP}-fpm \
        ${PHP}-cli \
        ${PHP}-curl \
        ${PHP}-ldap \
        ${PHP}-bcmath \
        ${PHP}-mbstring \
        ${PHP}-zip \
        ${PHP}-xml \
        ${PHP}-pecl-apcu \
    && apk add --virtual .build-deps \
        build-base pkgconf \
        ${PHP}-dev \
        ${PHP}-pear \
    && rm -rf /var/cache/apk/* \
    && pecl install mongodb

# Need some stuff here

# Set up Nginx (combine RUN commands)
# Upstream has these lines, but we want to save logs on the actual filesystem, so we'll leave them out for now.
#RUN ln -sf /dev/stderr /var/log/nginx/error.log && \
#    ln -sf /dev/stdout /var/log/nginx/access.log

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
RUN cp -v docker/prepare/set_nginx_htpasswd.sh /root/set_nginx_htpasswd.sh && \
    cp -v docker/config/nginx.conf /etc/nginx/nginx.conf && \
    cp -v docker/config/default.conf /etc/nginx/sites-available/default && \
    cp -v docker/supervisord.conf /etc/supervisor/conf.d/ && \
    rm -rf html && \
    chown -R nginx:nginx /var/www && \
    /root/set_nginx_htpasswd.sh && \
    mkdir -p /var/run/php


EXPOSE 80

CMD ["sh", "./scripts/start.sh"]
