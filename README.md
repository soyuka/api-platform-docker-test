# api-platform docker

php-fpm + nginx

# Install

```
git submodule update --init
docker-compose up -d
docker-compose run --rm php bin/console doctrine:schema:update --force
```
