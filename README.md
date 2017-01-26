# api-platform docker

php-fpm + nginx

# Install

```
git submodule update --init
docker-compose up -d
# fix permissions
docker-compose run --rm php chown -R $(id -u):$(id -g) .
docker-compose run --rm php bin/console doctrine:schema:update --force
```
