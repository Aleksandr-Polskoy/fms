#!/bin/bash

# Скрипт установки системы управления огородом с FastPanel
# Запуск: bash install_script.sh

set -e

echo "=== Установка системы управления огородом ==="

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Функции
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Проверка root прав
if [[ $EUID -ne 0 ]]; then
   log_error "Этот скрипт должен быть запущен с правами root"
   exit 1
fi

# Переменные
PROJECT_DIR="/opt/fms"
DOMAIN=""
DB_PASSWORD=""
OPENWEATHER_API_KEY=""
DEEPSEEK_API_KEY=""

# Запрос параметров
echo "Введите параметры установки:"
read -p "Доменное имя (например, fms.your-domain.com): " DOMAIN
read -s -p "Пароль для базы данных: " DB_PASSWORD
echo
read -p "API ключ OpenWeatherMap (опционально): " OPENWEATHER_API_KEY
read -p "API ключ Deepseek (опционально): " DEEPSEEK_API_KEY

log_info "Начинаем установку..."

# Этап 1: Обновление системы
log_info "Обновление системы..."
apt update && apt upgrade -y

# Этап 2: Установка необходимого ПО
log_info "Установка необходимого ПО..."
apt install -y nginx php8.1-fpm php8.1-mysql php8.1-xml php8.1-curl php8.1-mbstring php8.1-zip php8.1-gd mysql-server git unzip

# Установка Composer
log_info "Установка Composer..."
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

# Установка Node.js
log_info "Установка Node.js..."
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs

# Этап 3: Создание папки проекта
log_info "Создание папки проекта..."
mkdir -p $PROJECT_DIR
cd $PROJECT_DIR

# Этап 4: Клонирование проекта (замените на ваш репозиторий)
log_info "Клонирование проекта..."
# git clone https://github.com/ваш_репозиторий/fms.git .
# Или раскомментируйте строку выше и замените URL

# Этап 5: Настройка Backend
log_info "Настройка Backend..."
cd $PROJECT_DIR/backend

# Установка зависимостей
composer install --no-dev --optimize-autoloader

# Копирование конфигурации
cp .env.example .env

# Настройка .env файла
sed -i "s|APP_URL=.*|APP_URL=https://$DOMAIN|g" .env
sed -i "s|DB_DATABASE=.*|DB_DATABASE=fms_db|g" .env
sed -i "s|DB_USERNAME=.*|DB_USERNAME=fms_user|g" .env
sed -i "s|DB_PASSWORD=.*|DB_PASSWORD=$DB_PASSWORD|g" .env
sed -i "s|OPENWEATHER_API_KEY=.*|OPENWEATHER_API_KEY=$OPENWEATHER_API_KEY|g" .env
sed -i "s|DEEPSEEK_API_KEY=.*|DEEPSEEK_API_KEY=$DEEPSEEK_API_KEY|g" .env

# Генерация ключа и миграции
php artisan key:generate
php artisan migrate --force
php artisan config:cache
php artisan route:cache

# Установка прав
chmod -R 755 storage bootstrap/cache
chown -R www-data:www-data storage bootstrap/cache

# Этап 6: Настройка Frontend
log_info "Настройка Frontend..."
cd $PROJECT_DIR/frontend

# Установка зависимостей
npm install

# Обновление API URL в компонентах
find . -name "*.vue" -exec sed -i "s|http://localhost:8000|https://$DOMAIN/api|g" {} \;

# Сборка проекта
npm run build

# Этап 7: Настройка базы данных
log_info "Настройка базы данных..."
mysql -e "CREATE DATABASE IF NOT EXISTS fms_db;"
mysql -e "CREATE USER IF NOT EXISTS 'fms_user'@'localhost' IDENTIFIED BY '$DB_PASSWORD';"
mysql -e "GRANT ALL PRIVILEGES ON fms_db.* TO 'fms_user'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

# Импорт структуры БД
if [ -f "$PROJECT_DIR/dump.sql" ]; then
    mysql fms_db < $PROJECT_DIR/dump.sql
fi

# Этап 8: Настройка Nginx
log_info "Настройка Nginx..."

# Создание конфигурации для frontend
cat > /etc/nginx/sites-available/fms << EOF
server {
    listen 80;
    server_name $DOMAIN;
    root $PROJECT_DIR/frontend/dist;
    index index.html;

    # API проксирование
    location /api/ {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    # Статические файлы
    location / {
        try_files \$uri \$uri/ /index.html;
    }

    # Кэширование
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
EOF

# Создание конфигурации для backend
cat > /etc/nginx/sites-available/fms-api << EOF
server {
    listen 8000;
    server_name localhost;
    root $PROJECT_DIR/backend/public;
    index index.php;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
        include fastcgi_params;
    }
}
EOF

# Активация сайтов
ln -sf /etc/nginx/sites-available/fms /etc/nginx/sites-enabled/
ln -sf /etc/nginx/sites-available/fms-api /etc/nginx/sites-enabled/

# Удаление дефолтного сайта
rm -f /etc/nginx/sites-enabled/default

# Проверка конфигурации nginx
nginx -t

# Перезапуск nginx
systemctl restart nginx

# Этап 9: Настройка PHP-FPM
log_info "Настройка PHP-FPM..."
systemctl restart php8.1-fpm

# Этап 10: Настройка Cron
log_info "Настройка Cron..."
(crontab -l 2>/dev/null; echo "0 * * * * cd $PROJECT_DIR/backend && php artisan schedule:run") | crontab -

# Этап 11: Настройка прав
log_info "Настройка прав..."
chown -R www-data:www-data $PROJECT_DIR
chmod -R 755 $PROJECT_DIR

# Этап 12: Проверка установки
log_info "Проверка установки..."
if curl -s "http://$DOMAIN/api/cultures" > /dev/null; then
    log_info "API работает корректно!"
else
    log_warn "API может быть недоступен. Проверьте настройки nginx."
fi

# Вывод информации
echo
log_info "=== Установка завершена! ==="
echo
echo "Доступ к системе:"
echo "Frontend: https://$DOMAIN"
echo "API: https://$DOMAIN/api"
echo
echo "Данные для входа в БД:"
echo "База данных: fms_db"
echo "Пользователь: fms_user"
echo "Пароль: $DB_PASSWORD"
echo
echo "Следующие шаги:"
echo "1. Настройте SSL сертификат через FastPanel"
echo "2. Откройте https://$DOMAIN и протестируйте систему"
echo "3. Создайте первую культуру, поле и план"
echo
log_info "Установка завершена успешно!" 