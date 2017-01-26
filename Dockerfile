FROM alpine:edge

RUN apk --update --no-cache add \
        git \
        openssh \
	php7 \
	php7-posix \
	php7-ctype \
	php7-dom \
	php7-pdo \
	php7-pdo_mysql \
	php7-opcache \
	php7-fpm \
	php7-apcu \
	php7-openssl \
	php7-curl \
	php7-pcntl \
	php7-xml \
	php7-json \
	php7-phar \
	php7-iconv \
	php7-mbstring \
	php7-session \
	php7-mcrypt \
	php7-zlib \
	php7-cgi \
        su-exec

RUN ln -s /usr/bin/php7 /usr/bin/php

# add www-data user
RUN addgroup -S www-data && adduser -S -G www-data www-data

COPY ./docker/php/php.ini /etc/php7/php.ini
COPY ./docker/php/php-fpm.conf /etc/php7/php-fpm.conf

# install composer
COPY ./docker/php/composer.sh /
RUN chmod +x composer.sh \
    && sh composer.sh \
    && mv composer.phar /usr/bin/composer \
    && chmod +x /usr/bin/composer

# prepare volume directory
RUN mkdir /api-platform

WORKDIR /api-platform

# fix volume permissions
RUN chown -R www-data .

# speed up composer
RUN su-exec www-data composer global require hirak/prestissimo:^0.3

VOLUME /api-platform

EXPOSE 9000

COPY ./docker/php/docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
CMD ["docker-entrypoint.sh"]
