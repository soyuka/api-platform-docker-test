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

# install composer
COPY ./docker/php/composer.sh /
RUN chmod +x composer.sh \
    && sh composer.sh \
    && mv composer.phar /usr/bin/composer \
    && chmod +x /usr/bin/composer

# fix minimum stability
COPY ./docker/php/composer.json /home/www-data/.composer/composer.json

# prepare volume directory
RUN mkdir /home/www-data/api-platform

# fix permissions before composer global
RUN chown -R www-data:www-data /home/www-data

WORKDIR /home/www-data

# speed up composer
RUN su-exec www-data composer global require hirak/prestissimo:^0.3

# install php-pm
RUN su-exec www-data composer global require php-pm/php-pm:dev-master php-pm/httpkernel-adapter:dev-master

# configure php-pm
RUN su-exec www-data /home/www-data/.composer/vendor/bin/ppm config --cgi-path=/usr/bin/php-cgi7 --bootstrap=Symfony --bridge HttpKernel

VOLUME /home/www-data/api-platform

EXPOSE 8080

COPY ./docker/php/docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
CMD ["/usr/local/bin/docker-entrypoint.sh"]

# WORKDIR /home/www-data/api-platform
#
# RUN composer install --prefer-dist --no-scripts --no-progress --no-suggest --optimize-autoloader --classmap-authoritative

# CMD ["/home/www-data/.composer/vendor/bin/ppm", "start"]
# CMD ["/home/www-data/.composer/vendor/bin/ppm"]
