#!/bin/sh
set -xe

chown -R www-data .

cd api-platform

# Detect the host IP
export DOCKER_BRIDGE_IP=$(ip ro | grep default | cut -d' ' -f 3)

if [ "$SYMFONY_ENV" = 'dev' ]; then
    su-exec www-data composer install --prefer-dist --no-progress --no-suggest
else
    su-exec www-data composer install --prefer-dist --no-dev --no-progress --no-suggest --optimize-autoloader --classmap-authoritative
fi

exec su-exec www-data /home/www-data/.composer/vendor/bin/ppm start $(pwd)
