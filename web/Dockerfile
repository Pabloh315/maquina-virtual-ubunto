FROM composer:2 AS vendor

WORKDIR /var/www

COPY composer.json composer.lock ./
RUN composer install --no-dev --no-interaction --no-progress --prefer-dist --no-scripts

COPY . .
RUN composer dump-autoload --no-dev --classmap-authoritative --no-scripts

FROM node:22-alpine AS assets

WORKDIR /var/www

COPY package.json package-lock.json ./
RUN npm ci

COPY resources ./resources
COPY public ./public
COPY vite.config.js ./
RUN npm run build

FROM php:8.4-fpm-alpine AS app

RUN apk add --no-cache postgresql-libs \
    && apk add --no-cache --virtual .build-deps $PHPIZE_DEPS postgresql-dev \
    && docker-php-ext-install pdo_pgsql pgsql opcache \
    && apk del .build-deps

WORKDIR /var/www

COPY --from=vendor --chown=www-data:www-data /var/www /var/www
COPY --from=assets --chown=www-data:www-data /var/www/public/build /var/www/public/build

RUN mkdir -p storage/app/public storage/framework/cache/data storage/framework/sessions storage/framework/views storage/logs bootstrap/cache \
    && chown -R www-data:www-data storage bootstrap/cache

EXPOSE 9000

CMD ["php-fpm"]

FROM nginx:1.28-alpine AS nginx

COPY docker/nginx/default.conf /etc/nginx/conf.d/default.conf
COPY --from=vendor /var/www/public /var/www/public
COPY --from=assets /var/www/public/build /var/www/public/build

RUN ln -s /var/www/storage/app/public /var/www/public/storage

EXPOSE 80
