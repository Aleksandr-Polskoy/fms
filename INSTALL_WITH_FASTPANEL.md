# Установка системы управления огородом с FastPanel

## Этап 1: Установка FastPanel

### 1.1 Подключение к серверу
```bash
ssh root@ваш_сервер_ip
```

### 1.2 Установка FastPanel
```bash
# Скачивание установщика
wget https://download.fastpanel.direct/install_fastpanel.sh

# Установка
bash install_fastpanel.sh

# Следуйте инструкциям установщика
# Запомните логин и пароль для панели
```

### 1.3 Настройка FastPanel
1. Откройте `http://ваш_сервер_ip:8888`
2. Войдите в панель управления
3. Создайте домен для проекта (например, `fms.your-domain.com`)

## Этап 2: Подготовка сервера

### 2.1 Установка необходимого ПО
```bash
# Обновление системы
apt update && apt upgrade -y

# Установка PHP и расширений
apt install -y php8.1-fpm php8.1-mysql php8.1-xml php8.1-curl php8.1-mbstring php8.1-zip php8.1-gd

# Установка Composer
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

# Установка Node.js и npm
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs

# Установка Git
apt install -y git
```

### 2.2 Создание папки для проекта
```bash
# Создание папки вне FastPanel
mkdir -p /opt/fms
cd /opt/fms

# Установка прав
chown -R www-data:www-data /opt/fms
chmod -R 755 /opt/fms
```

## Этап 3: Установка Backend (Laravel)

### 3.1 Клонирование проекта
```bash
cd /opt/fms
git clone https://github.com/ваш_репозиторий/fms.git .
# Или загрузите файлы через FTP в папку /opt/fms/
```

### 3.2 Настройка Backend
```bash
cd /opt/fms/backend

# Установка зависимостей
composer install --no-dev --optimize-autoloader

# Копирование конфигурации
cp .env.example .env

# Настройка .env файла
nano .env
```

### 3.3 Настройка .env файла
```env
APP_NAME="FMS"
APP_ENV=production
APP_KEY=base64:ваш_ключ
APP_DEBUG=false
APP_URL=https://ваш-домен.com

DB_CONNECTION=mysql
DB_HOST=localhost
DB_DATABASE=fms_db
DB_USERNAME=fms_user
DB_PASSWORD=ваш_пароль

OPENWEATHER_API_KEY=ваш_ключ_openweather
DEEPSEEK_API_KEY=ваш_ключ_deepseek
DEEPSEEK_API_URL=https://api.deepseek.com/recommend
```

### 3.4 Генерация ключа и миграции
```bash
php artisan key:generate
php artisan migrate
php artisan config:cache
php artisan route:cache

# Установка прав
chmod -R 755 storage bootstrap/cache
chown -R www-data:www-data storage bootstrap/cache
```

## Этап 4: Установка Frontend (Vue)

### 4.1 Настройка Frontend
```bash
cd /opt/fms/frontend

# Установка зависимостей
npm install

# Обновление API URL в компонентах
# Замените все http://localhost:8000 на https://ваш-домен.com/api
```

### 4.2 Сборка проекта
```bash
npm run build
```

## Этап 5: Настройка базы данных

### 5.1 Создание БД через FastPanel
1. Войдите в FastPanel
2. Перейдите в "Базы данных"
3. Создайте новую БД: `fms_db`
4. Создайте пользователя: `fms_user`
5. Импортируйте файл `dump.sql`

### 5.2 Или через командную строку
```bash
mysql -u root -p
CREATE DATABASE fms_db;
CREATE USER 'fms_user'@'localhost' IDENTIFIED BY 'ваш_пароль';
GRANT ALL PRIVILEGES ON fms_db.* TO 'fms_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;

# Импорт структуры БД
mysql -u fms_user -p fms_db < /opt/fms/dump.sql
```

## Этап 6: Настройка Nginx через FastPanel

### 6.1 Создание конфигурации
В FastPanel создайте новый сайт и настройте:

```nginx
server {
    listen 80;
    server_name ваш-домен.com;
    root /opt/fms/frontend/dist;
    index index.html;

    # API проксирование
    location /api/ {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Статические файлы
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Кэширование
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

### 6.2 Настройка PHP-FPM
В FastPanel настройте PHP-FPM для backend:

```nginx
server {
    listen 8000;
    server_name localhost;
    root /opt/fms/backend/public;
    index index.php;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }
}
```

## Этап 7: Настройка SSL

### 7.1 Через FastPanel
1. Войдите в FastPanel
2. Перейдите в "SSL сертификаты"
3. Установите Let's Encrypt сертификат
4. Настройте автоматическое обновление

## Этап 8: Проверка установки

### 8.1 Проверка API
```bash
curl https://ваш-домен.com/api/cultures
# Должен вернуть JSON ответ
```

### 8.2 Проверка Frontend
1. Откройте `https://ваш-домен.com`
2. Проверьте все разделы
3. Протестируйте создание культуры, поля, плана

## Этап 9: Настройка автоматических задач

### 9.1 Настройка Cron
```bash
crontab -e
# Добавьте строки:
0 * * * * cd /opt/fms/backend && php artisan schedule:run
0 6 * * * cd /opt/fms/backend && php artisan weather:update
```

## Решение проблем

### Проблема 1: Ошибки 500
```bash
# Проверьте логи
tail -f /opt/fms/backend/storage/logs/laravel.log

# Проверьте права
chmod -R 755 /opt/fms/backend/storage
chown -R www-data:www-data /opt/fms/backend/storage
```

### Проблема 2: CORS ошибки
Добавьте в .env:
```env
CORS_ALLOWED_ORIGINS=https://ваш-домен.com
```

### Проблема 3: Ошибки API
Проверьте настройки nginx и убедитесь, что проксирование работает корректно.

## Обновление системы

### Обновление Backend
```bash
cd /opt/fms/backend
git pull
composer install --no-dev
php artisan migrate
php artisan config:cache
```

### Обновление Frontend
```bash
cd /opt/fms/frontend
git pull
npm install
npm run build
```

## Резервное копирование

### База данных
```bash
mysqldump -u fms_user -p fms_db > backup_$(date +%Y%m%d).sql
```

### Файлы
```bash
tar -czf fms_backup_$(date +%Y%m%d).tar.gz /opt/fms
```

## Контакты для поддержки

При возникновении проблем:
1. Проверьте логи в `/opt/fms/backend/storage/logs/`
2. Проверьте настройки nginx в FastPanel
3. Убедитесь, что все сервисы запущены 