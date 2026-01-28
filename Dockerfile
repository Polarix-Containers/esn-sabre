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
        ${PHP}-pecl-apcu \
    && apk add --virtual .build-deps \
        build-base pkgconf \
        ${PHP}-dev \
        ${PHP}-pear
    && rm -rf /var/cache/apk/* \
    && pecl install mongodb