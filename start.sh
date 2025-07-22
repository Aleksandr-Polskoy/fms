#!/bin/bash

# Скрипт быстрого запуска системы управления огородом с Docker

set -e

echo "=== Запуск системы управления огородом ==="

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

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

# Проверка Docker
if ! command -v docker &> /dev/null; then
    log_error "Docker не установлен. Установите Docker и попробуйте снова."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    log_error "Docker Compose не установлен. Установите Docker Compose и попробуйте снова."
    exit 1
fi

# Проверка .env файла
if [ ! -f ".env" ]; then
    log_info "Создание .env файла..."
    cp env.example .env
    log_warn "Отредактируйте .env файл и добавьте ваши API ключи (опционально)"
fi

# Остановка существующих контейнеров
log_info "Остановка существующих контейнеров..."
docker-compose down

# Удаление старых образов (опционально)
read -p "Удалить старые образы? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    log_info "Удаление старых образов..."
    docker-compose down --rmi all
fi

# Сборка и запуск
log_info "Сборка и запуск контейнеров..."
docker-compose up -d --build

# Ожидание запуска контейнеров
log_info "Ожидание запуска контейнеров..."
sleep 30

# Проверка статуса
log_info "Проверка статуса контейнеров..."
docker-compose ps

# Проверка API
log_info "Проверка API..."
if curl -s "http://localhost:8000/api/cultures" > /dev/null; then
    log_info "✅ API работает корректно!"
else
    log_warn "⚠️ API может быть недоступен. Проверьте логи:"
    docker-compose logs backend
fi

# Проверка Frontend
log_info "Проверка Frontend..."
if curl -s "http://localhost" > /dev/null; then
    log_info "✅ Frontend работает корректно!"
else
    log_warn "⚠️ Frontend может быть недоступен. Проверьте логи:"
    docker-compose logs nginx_frontend
fi

# Вывод информации
echo
log_info "=== Система запущена! ==="
echo
echo "Доступ к системе:"
echo "🌐 Frontend: http://localhost"
echo "🔧 Backend API: http://localhost:8000"
echo "🗄️ База данных: localhost:3306"
echo
echo "Управление:"
echo "📊 Статус: docker-compose ps"
echo "📋 Логи: docker-compose logs -f"
echo "🛑 Остановка: docker-compose down"
echo "🔄 Перезапуск: docker-compose restart"
echo
echo "База данных:"
echo "📊 База: fms_db"
echo "👤 Пользователь: fms_user"
echo "🔑 Пароль: fms_password"
echo
log_info "Система готова к использованию!" 