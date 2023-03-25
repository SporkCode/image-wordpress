FROM php:8.1-cli-alpine AS php-build

LABEL org.opencontainers.image.source="https://github.com/SporkCode/image-wordpress"

# Build PHP extensions
RUN apk add curl gcc libc-dev make php81-dev imagemagick-dev
RUN pecl install imagick 


FROM php:8.1-fpm-alpine as php

ARG WORDPRESS_VERSION=6.1.1

RUN addgroup php && addgroup -S www-data php
RUN apk add socat libzip-dev icu-dev libgomp imagemagick-libs
# Install PHP extensions
RUN docker-php-ext-install -j$(nproc) exif intl mysqli zip
COPY --from=php-build /usr/local/lib/php/extensions/no-debug-non-zts-20210902/* /usr/local/lib/php/extensions/no-debug-non-zts-20210902/
RUN docker-php-ext-enable imagick
# Wordpress
RUN curl https://wordpress.org/wordpress-${WORDPRESS_VERSION}.tar.gz | tar -xz -C /var/www/html --strip-components=1
COPY wp-config.php /var/www/html/wp-config.php
# Configure PHP FPM
COPY php-fpm.conf /usr/local/etc/php-fpm.d/zzz-www.conf


FROM nginx:1.23 AS nginx

RUN addgroup php && adduser nginx php
COPY --from=php /var/www/html /var/www/html
COPY fastcgi_params /etc/nginx/fastcgi_params
COPY nginx.conf /etc/nginx/conf.d/default.conf
