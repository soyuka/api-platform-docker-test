FROM php:7.0-fpm-alpine

# Git is for composer
# openssh for future security support see https://github.com/api-platform/api-platform/issues/109
# su-exec for managing permissions
RUN export BUILD_DEPS="zlib-dev icu-dev" \
    && apk --update --no-cache add \
        ${BUILD_DEPS} \
        git openssh su-exec \
        icu-libs zlib \
    && docker-php-ext-install \
        intl mbstring pdo_mysql zip \
    && apk del ${BUILD_DEPS}

COPY ./docker/php/php.ini /etc/php7/php.ini

# install composer
COPY ./docker/php/composer.sh composer.sh
RUN chmod +x composer.sh \
    && sh composer.sh \
    && mv composer.phar /usr/bin/composer \
    && chmod +x /usr/bin/composer

# prepare volume directory
RUN mkdir /api-platform

# speed up composer
RUN su-exec www-data composer global require hirak/prestissimo:^0.3

WORKDIR /api-platform

COPY ./docker/php/docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
CMD ["docker-entrypoint.sh"]
