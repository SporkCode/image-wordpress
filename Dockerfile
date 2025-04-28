ARG PHP_VERSION=8.4
ARG NGINX_VERSION=1.28


FROM alpine:3.21 AS wordpress

ARG WORDPRESS_VERSION=6.8

WORKDIR /src

RUN apk add --no-cache curl rsync

RUN curl https://wordpress.org/wordpress-${WORDPRESS_VERSION}.tar.gz | tar -xz

RUN rsync wordpress/ static --recursive --exclude='*.php'


FROM php:${PHP_VERSION}-fpm-alpine AS php

LABEL org.opencontainers.image.source=https://github.com/SporkCode/image-wordpress
LABEL org.opencontainers.image.description="wordpress-php"
LABEL org.opencontainers.image.licenses=MIT

RUN docker-php-ext-install mysqli

COPY --from=wordpress /src/wordpress /var/www/html

COPY ./php/wp-config.php /var/www/html/wp-config.php


FROM nginx:${NGINX_VERSION}-alpine AS nginx

LABEL org.opencontainers.image.source=https://github.com/SporkCode/image-wordpress
LABEL org.opencontainers.image.description="wordpress-nginx"
LABEL org.opencontainers.image.licenses=MIT

COPY ./nginx/default.conf /etc/nginx/conf.d/default.conf

COPY --from=wordpress /src/static /var/www/html
