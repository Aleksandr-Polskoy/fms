#!/bin/bash

# Скрипт очистки и переустановки системы

set -e

echo "=== Очистка и переустановка системы управления огородом ==="

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

log_info "Начинаем очистку старой установки..."

# Остановка и удаление старых контейнеров
log_info "Остановка старых контейнеров..."
if [ -d "$PROJECT_DIR" ]; then
    cd $PROJECT_DIR
    if [ -f "docker-compose-domain.yml" ]; then
        docker-compose -f docker-compose-domain.yml down
    fi
    if [ -f "docker-compose.yml" ]; then
        docker-compose -f docker-compose.yml down
    fi
fi

# Удаление старых образов
log_info "Удаление старых Docker образов..."
docker system prune -f

# Удаление старой папки проекта
log_info "Удаление старой папки проекта..."
rm -rf $PROJECT_DIR

# Создание новой папки
log_info "Создание новой папки проекта..."
mkdir -p $PROJECT_DIR
cd $PROJECT_DIR

# Клонирование репозитория
log_info "Клонирование репозитория..."
git clone https://github.com/Aleksandr-Polskoy/fms.git .

# Установка прав
chown -R www-data:www-data $PROJECT_DIR
chmod -R 755 $PROJECT_DIR

log_info "✅ Очистка завершена!"
echo
log_info "Теперь запустите новый скрипт установки:"
echo "cd $PROJECT_DIR"
echo "chmod +x install-server.sh"
echo "./install-server.sh"
echo
log_info "Или запустите этот скрипт для автоматической установки:"
echo "chmod +x install-server.sh && ./install-server.sh" 