#!/bin/bash

# Скрипт для запуска контейнеров системы управления огородом

set -e

echo "=== Запуск контейнеров системы управления огородом ==="

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

# Проверка root прав
if [[ $EUID -ne 0 ]]; then
   log_error "Этот скрипт должен быть запущен с правами root"
   exit 1
fi

PROJECT_DIR="/opt/fms"

# Переход в папку проекта
cd $PROJECT_DIR

log_info "Остановка существующих контейнеров..."
docker compose -f docker-compose-domain.yml down

log_info "Запуск контейнеров..."
docker compose -f docker-compose-domain.yml up -d --build

log_info "Ожидание запуска контейнеров..."
sleep 30

log_info "Проверка статуса контейнеров..."
docker compose -f docker-compose-domain.yml ps

log_info "Настройка Backend..."
docker exec fms_backend php artisan key:generate
docker exec fms_backend php artisan migrate --force
docker exec fms_backend php artisan config:cache
docker exec fms_backend php artisan route:cache

log_info "Проверка API..."
if curl -s "http://localhost:8000/api/cultures" > /dev/null; then
    log_info "✅ API работает корректно!"
else
    log_warn "⚠️ API может быть недоступен. Проверьте логи:"
    docker compose -f docker-compose-domain.yml logs backend
fi

echo
log_info "=== Контейнеры запущены! ==="
echo
echo "Доступ к системе:"
echo "🌐 Frontend: https://fms.devdemo.ru"
echo "🔧 Backend API: https://fms.devdemo.ru/api"
echo
echo "Управление:"
echo "📊 Статус: docker compose -f docker-compose-domain.yml ps"
echo "📋 Логи: docker compose -f docker-compose-domain.yml logs -f"
echo "🛑 Остановка: docker compose -f docker-compose-domain.yml down"
echo "🔄 Перезапуск: docker compose -f docker-compose-domain.yml restart"
echo
log_info "Система готова к использованию!" 