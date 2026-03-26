# PHP 8.2 ની જગ્યાએ 8.4 વાપરો
FROM php:8.4-cli

# બાકીનો બધો કોડ જેવો હતો એવો જ રહેવા દો...
RUN apt-get update && apt-get install -y \
    unzip git curl libpng-dev libonig-dev libxml2-dev zip libpq-dev

# PHP Extensions
RUN docker-php-ext-install pdo pdo_mysql pdo_pgsql mbstring exif pcntl bcmath gd

# Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

COPY composer.json composer.lock ./

# અહીં પણ --ignore-platform-reqs રાખજો જ
RUN composer install --no-scripts --no-autoloader --no-interaction --no-dev --ignore-platform-reqs

COPY . .

RUN mkdir -p storage/framework/cache/data \
    storage/framework/app/cache \
    storage/framework/sessions \
    storage/framework/views \
    bootstrap/cache \
    && chown -R www-data:www-data /var/www \
    && chmod -R 775 /var/www/storage /var/www/bootstrap/cache

# હવે આ કમાન્ડ એરર વગર ચાલશે
RUN composer dump-autoload --optimize --ignore-platform-reqs

EXPOSE 10000

CMD php artisan serve --host=0.0.0.0 --port=10000