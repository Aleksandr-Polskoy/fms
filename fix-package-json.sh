#!/bin/bash

# Скрипт для исправления package.json на сервере

echo "=== Исправление package.json ==="

# Создаем правильный package.json
cat > /opt/fms/frontend/package.json << 'EOF'
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

echo "✅ package.json исправлен!"

# Проверяем содержимое
echo "📋 Содержимое package.json:"
cat /opt/fms/frontend/package.json

echo ""
echo "🚀 Теперь запустите контейнеры:"
echo "docker compose -f docker-compose-domain.yml up -d --build" 