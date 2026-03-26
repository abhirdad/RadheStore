FROM php:8.2-cli

# જરૂરી સિસ્ટમ લાઈબ્રેરીઓ
RUN apt-get update && apt-get install -y \
    unzip \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    libpq-dev

# PHP Extensions ઇન્સ્ટોલ કરો (PostgreSQL માટે pdo_pgsql ઉમેર્યું છે)
RUN docker-php-ext-install pdo pdo_mysql pdo_pgsql mbstring exif pcntl bcmath gd

# Composer મેળવો
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

# પહેલા ફક્ત composer ફાઈલો કોપી કરો (આનાથી સ્પીડ વધશે)
COPY composer.json composer.lock ./

# Dependencies ઇન્સ્ટોલ કરો (વધારે મેમરી ન વપરાય તે માટેના ઓપ્શન્સ સાથે)
RUN composer install --no-scripts --no-autoloader --no-interaction --no-dev

# હવે બાકીનો બધો કોડ કોપી કરો
COPY . .

# Autoloader ફાઈનલ કરો
RUN composer dump-autoload --optimize

# Permissions આપો (Render માટે જરૂરી છે)
RUN chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache

# પોર્ટ સેટ કરો
EXPOSE 10000

# એપ શરૂ કરો
CMD php artisan serve --host=0.0.0.0 --port=10000