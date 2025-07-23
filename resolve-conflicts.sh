#!/bin/bash

# Скрипт для разрешения конфликтов git на сервере

echo "=== Разрешение конфликтов git ==="

cd /opt/fms

echo "📋 Сохраняем текущие изменения..."
git stash

echo "📋 Удаляем конфликтующие файлы..."
rm -f fix-package-json.sh
rm -f start-containers.sh

echo "📋 Обновляем репозиторий..."
git pull

echo "📋 Восстанавливаем изменения..."
git stash pop

echo "📋 Исправляем package.json..."
cat > frontend/package.json << 'EOF'
{
  "name": "fms-frontend",
  "version": "1.0.0",
  "description": "Frontend for Farm Management System",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview",
    "serve": "vite preview"
  },
  "dependencies": {
    "vue": "^3.3.4",
    "vue-router": "^4.2.4",
    "leaflet": "^1.9.4"
  },
  "devDependencies": {
    "@vitejs/plugin-vue": "^4.2.3",
    "vite": "^4.4.5"
  },
  "author": "Aleksandr Polskoy",
  "license": "MIT"
}
EOF

echo "✅ Конфликты разрешены!"
echo "📋 Проверяем package.json:"
cat frontend/package.json

echo ""
echo "🚀 Теперь запустите контейнеры:"
echo "docker compose -f docker-compose-domain.yml up -d --build" 