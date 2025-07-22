# 🚀 Установка системы управления огородом на сервер с FastPanel

## 📋 Подготовка

### Требования к серверу:
- **ОС**: Ubuntu 20.04+ или CentOS 8+
- **RAM**: минимум 2GB (рекомендуется 4GB)
- **Диск**: минимум 10GB свободного места
- **Домен**: fms.devdemo.ru (уже настроен в FastPanel)

## 🛠 Этап 1: Подключение к серверу

```bash
# Подключитесь к серверу
ssh root@ваш_сервер_ip

# Обновите систему
apt update && apt upgrade -y
```

## 🐳 Этап 2: Установка Docker

```bash
# Установка необходимых пакетов
apt install -y apt-transport-https ca-certificates curl gnupg lsb-release

# Добавление GPG ключа Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Добавление репозитория Docker
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Обновление и установка Docker
apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Проверка установки
docker --version
docker-compose --version

# Добавление пользователя в группу docker
usermod -aG docker $USER
```

## 📁 Этап 3: Подготовка проекта

```bash
# Создание папки проекта
mkdir -p /opt/fms
cd /opt/fms

# Клонирование репозитория
git clone https://github.com/Aleksandr-Polskoy/fms.git .

# Установка прав
chown -R www-data:www-data /opt/fms
chmod -R 755 /opt/fms
```

## ⚙️ Этап 4: Настройка переменных окружения

### 4.1 Автоматическая настройка (рекомендуется)

```bash
# Запуск автоматического скрипта
chmod +x install-server.sh
./install-server.sh
```

Скрипт запросит следующие параметры:
- **Название базы данных** (по умолчанию: fms_db)
- **Пользователь базы данных** (по умолчанию: fms_user)
- **Пароль для базы данных**
- **Пароль root для базы данных**
- **API ключ OpenWeatherMap** (опционально)
- **API ключ Deepseek** (опционально)

### 4.2 Ручная настройка

```bash
# Создание .env файла
cp env.example .env
nano .env
```

Добавьте в `.env`:
```env
# API ключи (опционально)
OPENWEATHER_API_KEY=ваш_ключ_openweather
DEEPSEEK_API_KEY=ваш_ключ_deepseek

# Настройки базы данных
MYSQL_ROOT_PASSWORD=ваш_сложный_пароль
MYSQL_DATABASE=ваше_название_базы
MYSQL_USER=ваш_пользователь
MYSQL_PASSWORD=ваш_сложный_пароль

# URL приложения
APP_URL=https://fms.devdemo.ru
```

Также отредактируйте `docker-compose-domain.yml`:
```yaml
mysql:
  environment:
    MYSQL_ROOT_PASSWORD: ваш_сложный_пароль
    MYSQL_DATABASE: ваше_название_базы
    MYSQL_USER: ваш_пользователь
    MYSQL_PASSWORD: ваш_сложный_пароль
```

## 🚀 Этап 5: Запуск приложения

```bash
# Остановка существующих контейнеров (если есть)
docker-compose -f docker-compose-domain.yml down

# Сборка и запуск контейнеров
docker-compose -f docker-compose-domain.yml up -d --build

# Проверка статуса
docker-compose -f docker-compose-domain.yml ps
```

## 🔧 Этап 6: Настройка Backend

```bash
# Вход в контейнер backend
docker exec -it fms_backend bash

# Настройка Laravel
php artisan key:generate
php artisan migrate --force
php artisan config:cache
php artisan route:cache

# Выход из контейнера
exit
```

## 🌐 Этап 7: Настройка FastPanel

### 7.1 Вход в FastPanel
1. Откройте `http://ваш_сервер_ip:8888`
2. Войдите в панель управления
3. Найдите сайт `fms.devdemo.ru`

### 7.2 Настройка nginx конфигурации
В FastPanel для сайта `fms.devdemo.ru` создайте следующую конфигурацию:

```nginx
server {
    listen 80;
    server_name fms.devdemo.ru;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name fms.devdemo.ru;
    
    # SSL настройки (FastPanel добавит автоматически)
    
    # Frontend (статичные файлы)
    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
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
}
```

## 🔐 Этап 8: Настройка SSL

### 8.1 Через FastPanel
1. Войдите в FastPanel
2. Перейдите в "SSL сертификаты"
3. Выберите сайт `fms.devdemo.ru`
4. Установите Let's Encrypt сертификат
5. Включите автоматическое обновление

## 📊 Этап 9: Проверка установки

### 9.1 Проверка контейнеров
```bash
# Статус контейнеров
docker-compose -f docker-compose-domain.yml ps

# Логи контейнеров
docker-compose -f docker-compose-domain.yml logs -f
```

### 9.2 Проверка API
```bash
# Проверка API
curl https://fms.devdemo.ru/api/cultures

# Проверка Frontend
curl https://fms.devdemo.ru
```

### 9.3 Проверка базы данных
```bash
# Подключение к MySQL (используйте ваши параметры)
docker exec -it fms_mysql mysql -u ваш_пользователь -p ваша_база

# Проверка таблиц
SHOW TABLES;
```

## 🔧 Управление системой

### Просмотр статуса
```bash
docker-compose -f docker-compose-domain.yml ps
```

### Просмотр логов
```bash
# Все контейнеры
docker-compose -f docker-compose-domain.yml logs -f

# Конкретный контейнер
docker-compose -f docker-compose-domain.yml logs -f backend
```

### Перезапуск
```bash
# Все контейнеры
docker-compose -f docker-compose-domain.yml restart

# Конкретный контейнер
docker-compose -f docker-compose-domain.yml restart backend
```

### Остановка
```bash
docker-compose -f docker-compose-domain.yml down
```

## 📈 Обновление системы

### Обновление кода
```bash
cd /opt/fms
git pull
docker-compose -f docker-compose-domain.yml up -d --build
docker exec fms_backend php artisan migrate
```

### Обновление переменных окружения
```bash
nano .env
docker-compose -f docker-compose-domain.yml restart
```

## 🚨 Решение проблем

### Проблема 1: Контейнеры не запускаются
```bash
# Проверьте логи
docker-compose -f docker-compose-domain.yml logs

# Проверьте порты
netstat -tulpn | grep :8000
netstat -tulpn | grep :3000
```

### Проблема 2: Ошибки базы данных
```bash
# Проверьте статус MySQL
docker exec fms_mysql mysqladmin -u root -p ping

# Проверьте логи MySQL
docker-compose -f docker-compose-domain.yml logs mysql
```

### Проблема 3: CORS ошибки
Проверьте nginx конфигурацию в FastPanel.

### Проблема 4: SSL ошибки
Проверьте настройки SSL в FastPanel.

## 📋 Чек-лист установки

- [ ] Docker установлен
- [ ] Репозиторий склонирован
- [ ] Параметры БД настроены
- [ ] .env файл настроен
- [ ] Контейнеры запущены
- [ ] Backend настроен
- [ ] FastPanel настроен
- [ ] SSL сертификат установлен
- [ ] API работает
- [ ] Frontend доступен

## 🎯 Готово!

После выполнения всех этапов ваша система будет доступна по адресу:
- **Frontend**: https://fms.devdemo.ru
- **Backend API**: https://fms.devdemo.ru/api

**Система готова к использованию!** 🚀 