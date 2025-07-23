#!/bin/bash

# Финальный скрипт настройки после исправления package.json

echo "=== Финальная настройка системы ==="

cd /opt/fms

echo "📋 Обновляем репозиторий..."
git add .
git commit -m "Fix package.json and resolve conflicts"
git pull

echo "📋 Останавливаем контейнеры..."
docker compose -f docker-compose-domain.yml down

echo "📋 Запускаем контейнеры..."
docker compose -f docker-compose-domain.yml up -d --build

echo "📋 Ожидаем запуска контейнеров..."
sleep 30

echo "📋 Проверяем статус контейнеров..."
docker compose -f docker-compose-domain.yml ps

echo "📋 Настраиваем Backend..."
docker exec fms_backend php artisan key:generate
docker exec fms_backend php artisan migrate --force
docker exec fms_backend php artisan config:cache
docker exec fms_backend php artisan route:cache

echo "📋 Проверяем API..."
if curl -s "http://localhost:8000/api/cultures" > /dev/null; then
    echo "✅ API работает корректно!"
else
    echo "⚠️ API может быть недоступен. Проверьте логи:"
    docker compose -f docker-compose-domain.yml logs backend
fi

echo ""
echo "🎉 === Система готова! ==="
echo ""
echo "Доступ к системе:"
echo "🌐 Frontend: https://fms.devdemo.ru"
echo "🔧 Backend API: https://fms.devdemo.ru/api"
echo ""
echo "Управление:"
echo "📊 Статус: docker compose -f docker-compose-domain.yml ps"
echo "📋 Логи: docker compose -f docker-compose-domain.yml logs -f"
echo "🛑 Остановка: docker compose -f docker-compose-domain.yml down"
echo "🔄 Перезапуск: docker compose -f docker-compose-domain.yml restart"
echo ""
echo "Следующие шаги:"
echo "1. Настройте nginx конфигурацию в FastPanel"
echo "2. Установите SSL сертификат через FastPanel"
echo "3. Откройте https://fms.devdemo.ru и протестируйте систему" 