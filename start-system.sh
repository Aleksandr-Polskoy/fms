#!/bin/bash

# Скрипт для полного запуска системы управления огородом

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

# Проверка root прав
if [[ $EUID -ne 0 ]]; then
   log_error "Этот скрипт должен быть запущен с правами root"
   exit 1
fi

cd /opt/fms

log_info "Остановка всех контейнеров..."
docker compose -f docker-compose-domain.yml down

log_info "Очистка Docker кэша..."
docker system prune -f

log_info "Запуск контейнеров..."
docker compose -f docker-compose-domain.yml up -d --build

log_info "Ожидание запуска контейнеров..."
sleep 60

log_info "Проверка статуса контейнеров..."
docker compose -f docker-compose-domain.yml ps

log_info "Настройка Backend..."
docker exec fms_backend php artisan key:generate
docker exec fms_backend php artisan migrate --force
docker exec fms_backend php artisan config:cache
docker exec fms_backend php artisan route:cache

log_info "Проверка портов..."
echo "📋 Проверка порта 9000 (Backend):"
ss -tulpn | grep :9000 || echo "❌ Порт 9000 не открыт"

echo "📋 Проверка порта 80 (Frontend):"
ss -tulpn | grep :80 || echo "❌ Порт 80 не открыт"

log_info "Проверка API..."
if curl -s "http://localhost/api/cultures" > /dev/null; then
    log_info "✅ API работает корректно!"
else
    log_warn "⚠️ API недоступен. Проверьте логи:"
    docker compose -f docker-compose-domain.yml logs backend --tail=20
fi

log_info "Проверка Frontend..."
if curl -s "http://localhost" > /dev/null; then
    log_info "✅ Frontend работает корректно!"
else
    log_warn "⚠️ Frontend недоступен. Проверьте логи:"
    docker compose -f docker-compose-domain.yml logs frontend --tail=20
fi

echo ""
log_info "=== Система запущена! ==="
echo ""
echo "📊 Статус контейнеров:"
docker compose -f docker-compose-domain.yml ps
echo ""
echo "🌐 Доступ к системе:"
echo "Frontend: http://fms.devdemo.ru"
echo "Backend API: http://fms.devdemo.ru/api"
echo ""
echo "📋 Следующие шаги:"
echo "1. Настройте nginx конфигурацию в FastPanel"
echo "2. Установите SSL сертификат"
echo "3. Протестируйте систему"
echo ""
echo "🔧 Управление:"
echo "Статус: docker compose -f docker-compose-domain.yml ps"
echo "Логи: docker compose -f docker-compose-domain.yml logs -f"
echo "Остановка: docker compose -f docker-compose-domain.yml down"
echo "Перезапуск: docker compose -f docker-compose-domain.yml restart" 