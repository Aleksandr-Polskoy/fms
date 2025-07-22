# Установка системы управления огородом с Docker

## Быстрый старт

### 1. Подготовка

Убедитесь, что у вас установлены:
- Docker
- Docker Compose

### 2. Настройка переменных окружения

Скопируйте файл с переменными:
```bash
cp env.example .env
```

Отредактируйте `.env` файл и добавьте ваши API ключи (опционально):
```bash
nano .env
```

### 3. Запуск системы

```bash
# Сборка и запуск всех контейнеров
docker-compose up -d --build

# Просмотр логов
docker-compose logs -f

# Остановка
docker-compose down
```

### 4. Доступ к системе

- **Frontend**: http://ваш_ip_адрес
- **Backend API**: http://ваш_ip_адрес:8000
- **База данных**: localhost:3306

## Структура контейнеров

### MySQL (База данных)
- **Порт**: 3306
- **База данных**: fms_db
- **Пользователь**: fms_user
- **Пароль**: fms_password

### Backend (Laravel)
- **Контейнер**: fms_backend
- **PHP-FPM**: 9000
- **Зависимости**: MySQL

### Nginx Backend
- **Контейнер**: fms_nginx_backend
- **Порт**: 8000
- **Проксирует**: Backend API

### Frontend Builder
- **Контейнер**: fms_frontend_builder
- **Собирает**: Vue.js приложение
- **Результат**: Статические файлы

### Nginx Frontend
- **Контейнер**: fms_nginx_frontend
- **Порт**: 80
- **Раздает**: Собранное Vue.js приложение
- **Проксирует**: API запросы к backend

## Управление

### Просмотр статуса
```bash
docker-compose ps
```

### Просмотр логов
```bash
# Все контейнеры
docker-compose logs -f

# Конкретный контейнер
docker-compose logs -f backend
docker-compose logs -f nginx_frontend
```

### Перезапуск
```bash
# Все контейнеры
docker-compose restart

# Конкретный контейнер
docker-compose restart backend
```

### Обновление кода
```bash
# Остановка
docker-compose down

# Пересборка
docker-compose up -d --build
```

## База данных

### Подключение к MySQL
```bash
docker exec -it fms_mysql mysql -u fms_user -p fms_db
```

### Резервное копирование
```bash
# Создание бэкапа
docker exec fms_mysql mysqldump -u fms_user -p fms_db > backup.sql

# Восстановление
docker exec -i fms_mysql mysql -u fms_user -p fms_db < backup.sql
```

### Импорт данных
```bash
# Импорт dump.sql
docker exec -i fms_mysql mysql -u fms_user -p fms_db < dump.sql
```

## Отладка

### Проверка API
```bash
curl http://ваш_ip_адрес:8000/api/cultures
```

### Проверка Frontend
```bash
curl http://ваш_ip_адрес
```

### Вход в контейнер
```bash
# Backend
docker exec -it fms_backend bash

# Frontend
docker exec -it fms_nginx_frontend sh

# MySQL
docker exec -it fms_mysql bash
```

## Настройка для продакшена

### 1. Изменение портов
Отредактируйте `docker-compose.yml`:
```yaml
ports:
  - "8080:80"  # Frontend на порту 8080
  - "8001:8000"  # Backend на порту 8001
```

### 2. Настройка SSL
Добавьте SSL сертификаты в nginx конфигурации.

### 3. Настройка домена
Измените `server_name` в nginx конфигурациях.

## Решение проблем

### Проблема 1: Контейнеры не запускаются
```bash
# Проверьте логи
docker-compose logs

# Проверьте порты
netstat -tulpn | grep :80
netstat -tulpn | grep :8000
```

### Проблема 2: Ошибки базы данных
```bash
# Проверьте статус MySQL
docker exec fms_mysql mysqladmin -u root -p ping

# Проверьте логи MySQL
docker-compose logs mysql
```

### Проблема 3: CORS ошибки
Проверьте nginx конфигурацию в `nginx/frontend.conf`.

### Проблема 4: Ошибки сборки Frontend
```bash
# Пересоберите frontend
docker-compose build frontend_builder
docker-compose up -d frontend_builder
```

## Мониторинг

### Использование ресурсов
```bash
docker stats
```

### Размер контейнеров
```bash
docker system df
```

### Очистка
```bash
# Удаление неиспользуемых образов
docker image prune

# Удаление неиспользуемых томов
docker volume prune
```

## Обновление системы

### 1. Остановка
```bash
docker-compose down
```

### 2. Обновление кода
```bash
git pull
```

### 3. Пересборка
```bash
docker-compose up -d --build
```

### 4. Миграции базы данных
```bash
docker exec fms_backend php artisan migrate
``` 