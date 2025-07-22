# Настройка системы с доменом fms.devdemo.ru через FastPanel

## Этап 1: Подготовка файлов на сервере

### 1.1 Подключение к серверу
```bash
ssh root@ваш_сервер_ip
```

### 1.2 Создание папки проекта
```bash
# Создаем папку вне FastPanel
mkdir -p /opt/fms
cd /opt/fms

# Устанавливаем права
chown -R www-data:www-data /opt/fms
chmod -R 755 /opt/fms
```

### 1.3 Загрузка файлов проекта
```bash
# Клонируем проект (замените на ваш репозиторий)
git clone https://github.com/ваш_репозиторий/fms.git .

# Или загрузите файлы через FTP/SFTP в папку /opt/fms/
```

## Этап 2: Настройка Docker для домена

### 2.1 Обновление docker-compose.yml
Создайте новый файл `docker-compose-domain.yml`:

```yaml
version: '3.8'

services:
  # MySQL база данных
  mysql:
    image: mysql:8.0
    container_name: fms_mysql
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: root_password
      MYSQL_DATABASE: fms_db
      MYSQL_USER: fms_user
      MYSQL_PASSWORD: fms_password
    volumes:
      - mysql_data:/var/lib/mysql
      - ./dump.sql:/docker-entrypoint-initdb.d/dump.sql
    networks:
      - fms_network

  # PHP Backend (Laravel)
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: fms_backend
    restart: unless-stopped
    environment:
      APP_NAME: "FMS"
      APP_ENV: production
      APP_DEBUG: "false"
      APP_URL: https://fms.devdemo.ru
      DB_CONNECTION: mysql
      DB_HOST: mysql
      DB_PORT: 3306
      DB_DATABASE: fms_db
      DB_USERNAME: fms_user
      DB_PASSWORD: fms_password
      OPENWEATHER_API_KEY: ${OPENWEATHER_API_KEY:-}
      DEEPSEEK_API_KEY: ${DEEPSEEK_API_KEY:-}
      DEEPSEEK_API_URL: https://api.deepseek.com/recommend
    volumes:
      - ./backend:/var/www/html
      - backend_storage:/var/www/html/storage
    depends_on:
      - mysql
    networks:
      - fms_network

  # Nginx для Backend (внутренний)
  nginx_backend:
    image: nginx:alpine
    container_name: fms_nginx_backend
    restart: unless-stopped
    volumes:
      - ./nginx/backend-domain.conf:/etc/nginx/conf.d/default.conf
      - ./backend:/var/www/html
    depends_on:
      - backend
    networks:
      - fms_network

  # Node.js для сборки Frontend
  frontend_builder:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    container_name: fms_frontend_builder
    volumes:
      - ./frontend:/app
      - frontend_dist:/app/dist
    environment:
      - API_URL=https://fms.devdemo.ru/api
    command: sh -c "npm install && npm run build"
    networks:
      - fms_network

volumes:
  mysql_data:
  backend_storage:
  frontend_dist:

networks:
  fms_network:
    driver: bridge
```

### 2.2 Создание nginx конфигурации для домена
Создайте файл `nginx/backend-domain.conf`:

```nginx
server {
    listen 80;
    server_name localhost;
    root /var/www/html/public;
    index index.php;

    # Логи
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    # Основные настройки
    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    # Обработка PHP файлов
    location ~ \.php$ {
        fastcgi_pass backend:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
        
        # Дополнительные параметры
        fastcgi_param PATH_INFO $fastcgi_path_info;
        fastcgi_param HTTP_AUTHORIZATION $http_authorization;
    }

    # Кэширование статических файлов
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Запрет доступа к системным файлам
    location ~ /\. {
        deny all;
    }

    location ~ /(vendor|storage|bootstrap) {
        deny all;
    }
}
```

## Этап 3: Настройка FastPanel

### 3.1 Вход в FastPanel
1. Откройте `http://ваш_сервер_ip:8888`
2. Войдите в панель управления
3. Найдите сайт `fms.devdemo.ru`

### 3.2 Настройка домена
1. В FastPanel перейдите в раздел "Сайты"
2. Найдите `fms.devdemo.ru`
3. Нажмите "Настройки" или "Редактировать"

### 3.3 Настройка DNS
Убедитесь, что DNS записи настроены:
- A запись: `fms.devdemo.ru` → IP вашего сервера
- CNAME запись: `www.fms.devdemo.ru` → `fms.devdemo.ru`

## Этап 4: Настройка Nginx в FastPanel

### 4.1 Создание конфигурации
В FastPanel для сайта `fms.devdemo.ru` создайте следующую конфигурацию:

```nginx
server {
    listen 80;
    server_name fms.devdemo.ru;
    root /opt/fms/frontend/dist;
    index index.html;

    # API проксирование
    location /api/ {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # CORS заголовки
        add_header Access-Control-Allow-Origin *;
        add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS";
        add_header Access-Control-Allow-Headers "DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization";
        
        # Обработка preflight запросов
        if ($request_method = 'OPTIONS') {
            add_header Access-Control-Allow-Origin *;
            add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS";
            add_header Access-Control-Allow-Headers "DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization";
            add_header Access-Control-Max-Age 1728000;
            add_header Content-Type 'text/plain; charset=utf-8';
            add_header Content-Length 0;
            return 204;
        }
    }

    # Статические файлы
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Кэширование статических файлов
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Gzip сжатие
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/json
        application/javascript
        application/xml+rss
        application/atom+xml
        image/svg+xml;
}
```

## Этап 5: Запуск системы

### 5.1 Настройка переменных
```bash
cd /opt/fms
cp env.example .env
nano .env
```

Добавьте ваши API ключи:
```env
OPENWEATHER_API_KEY=ваш_ключ_openweather
DEEPSEEK_API_KEY=ваш_ключ_deepseek
```

### 5.2 Запуск Docker контейнеров
```bash
# Сборка и запуск
docker-compose -f docker-compose-domain.yml up -d --build

# Проверка статуса
docker-compose -f docker-compose-domain.yml ps
```

### 5.3 Настройка Backend
```bash
# Вход в контейнер backend
docker exec -it fms_backend bash

# Настройка Laravel
php artisan key:generate
php artisan migrate
php artisan config:cache
php artisan route:cache

# Выход из контейнера
exit
```

### 5.4 Сборка Frontend
```bash
# Сборка frontend
docker-compose -f docker-compose-domain.yml up frontend_builder

# Проверка, что файлы собраны
ls -la /opt/fms/frontend/dist/
```

## Этап 6: Настройка SSL

### 6.1 Через FastPanel
1. Войдите в FastPanel
2. Перейдите в "SSL сертификаты"
3. Выберите сайт `fms.devdemo.ru`
4. Установите Let's Encrypt сертификат
5. Включите автоматическое обновление

### 6.2 Обновление конфигурации для HTTPS
После установки SSL обновите конфигурацию nginx в FastPanel:

```nginx
server {
    listen 80;
    server_name fms.devdemo.ru;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name fms.devdemo.ru;
    root /opt/fms/frontend/dist;
    index index.html;

    # SSL настройки (FastPanel добавит автоматически)
    
    # API проксирование
    location /api/ {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # CORS заголовки
        add_header Access-Control-Allow-Origin *;
        add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS";
        add_header Access-Control-Allow-Headers "DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization";
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

## Этап 7: Проверка установки

### 7.1 Проверка API
```bash
curl https://fms.devdemo.ru/api/cultures
```

### 7.2 Проверка Frontend
Откройте в браузере: `https://fms.devdemo.ru`

### 7.3 Проверка логов
```bash
# Логи backend
docker-compose -f docker-compose-domain.yml logs backend

# Логи nginx
docker-compose -f docker-compose-domain.yml logs nginx_backend
```

## Этап 8: Управление системой

### 8.1 Команды управления
```bash
# Статус
docker-compose -f docker-compose-domain.yml ps

# Логи
docker-compose -f docker-compose-domain.yml logs -f

# Перезапуск
docker-compose -f docker-compose-domain.yml restart

# Остановка
docker-compose -f docker-compose-domain.yml down
```

### 8.2 Обновление системы
```bash
# Остановка
docker-compose -f docker-compose-domain.yml down

# Обновление кода
git pull

# Пересборка
docker-compose -f docker-compose-domain.yml up -d --build

# Миграции
docker exec fms_backend php artisan migrate
```

## Решение проблем

### Проблема 1: Ошибки 500
```bash
# Проверьте логи
docker-compose -f docker-compose-domain.yml logs backend

# Проверьте права
docker exec fms_backend chmod -R 755 storage bootstrap/cache
```

### Проблема 2: CORS ошибки
Проверьте nginx конфигурацию в FastPanel.

### Проблема 3: Ошибки базы данных
```bash
# Проверьте статус MySQL
docker exec fms_mysql mysqladmin -u root -p ping

# Проверьте логи
docker-compose -f docker-compose-domain.yml logs mysql
```

## Готово!

После выполнения всех этапов ваша система будет доступна по адресу:
- **Frontend**: https://fms.devdemo.ru
- **Backend API**: https://fms.devdemo.ru/api 