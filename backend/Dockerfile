FROM php:8.1-fpm

# Установка системных зависимостей
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    libzip-dev \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip

# Установка Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Создание рабочей директории
WORKDIR /var/www/html

# Копирование composer файлов
COPY composer.json composer.lock ./

# Установка зависимостей
RUN composer install --no-dev --optimize-autoloader

# Копирование исходного кода
COPY . .

# Установка прав
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage \
    && chmod -R 755 /var/www/html/bootstrap/cache

# Создание .env файла
RUN cp .env.example .env

# Генерация ключа приложения
RUN php artisan key:generate

# Очистка кэша
RUN php artisan config:cache \
    && php artisan route:cache \
    && php artisan view:cache

# Открытие порта
EXPOSE 9000

# Запуск PHP-FPM
CMD ["php-fpm"] 