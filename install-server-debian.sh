#!/bin/bash

# Автоматизированная установка системы управления огородом на сервер (Debian)

set -e

echo "=== Установка системы управления огородом на сервер (Debian) ==="

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

# Переменные
PROJECT_DIR="/opt/fms"
DOMAIN="fms.devdemo.ru"

# Запрос параметров
echo "Введите параметры установки:"
echo

# Параметры базы данных
read -p "Название базы данных [fms_db]: " DB_NAME
DB_NAME=${DB_NAME:-fms_db}

read -p "Пользователь базы данных [fms_user]: " DB_USER
DB_USER=${DB_USER:-fms_user}

read -s -p "Пароль для базы данных: " DB_PASSWORD
echo

read -s -p "Пароль root для базы данных: " DB_ROOT_PASSWORD
echo

# API ключи
read -p "API ключ OpenWeatherMap (опционально): " OPENWEATHER_API_KEY
read -p "API ключ Deepseek (опционально): " DEEPSEEK_API_KEY

log_info "Начинаем установку..."

# Этап 1: Обновление системы
log_info "Обновление системы..."
apt update && apt upgrade -y

# Этап 2: Установка Docker для Debian
log_info "Установка Docker для Debian..."

# Удаление старых версий Docker
apt remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true

# Установка необходимых пакетов
apt install -y apt-transport-https ca-certificates curl gnupg lsb-release

# Добавление GPG ключа Docker
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Добавление репозитория Docker для Debian
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Обновление и установка Docker
apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Проверка установки
docker --version
docker-compose --version

# Добавление пользователя в группу docker
usermod -aG docker $USER

# Этап 3: Подготовка проекта
log_info "Подготовка проекта..."
mkdir -p $PROJECT_DIR
cd $PROJECT_DIR

# Клонирование репозитория
git clone https://github.com/Aleksandr-Polskoy/fms.git .

# Установка прав
chown -R www-data:www-data $PROJECT_DIR
chmod -R 755 $PROJECT_DIR

# Этап 4: Настройка переменных окружения
log_info "Настройка переменных окружения..."
cp env.example .env

# Обновление .env файла с параметрами БД
sed -i "s|OPENWEATHER_API_KEY=.*|OPENWEATHER_API_KEY=$OPENWEATHER_API_KEY|g" .env
sed -i "s|DEEPSEEK_API_KEY=.*|DEEPSEEK_API_KEY=$DEEPSEEK_API_KEY|g" .env

# Обновление docker-compose-domain.yml с параметрами БД
sed -i "s|MYSQL_DATABASE=.*|MYSQL_DATABASE=$DB_NAME|g" docker-compose-domain.yml
sed -i "s|MYSQL_USER=.*|MYSQL_USER=$DB_USER|g" docker-compose-domain.yml
sed -i "s|MYSQL_PASSWORD=.*|MYSQL_PASSWORD=$DB_PASSWORD|g" docker-compose-domain.yml
sed -i "s|MYSQL_ROOT_PASSWORD=.*|MYSQL_ROOT_PASSWORD=$DB_ROOT_PASSWORD|g" docker-compose-domain.yml

# Этап 5: Запуск приложения
log_info "Запуск приложения..."
docker-compose -f docker-compose-domain.yml down
docker-compose -f docker-compose-domain.yml up -d --build

# Ожидание запуска контейнеров
log_info "Ожидание запуска контейнеров..."
sleep 30

# Этап 6: Настройка Backend
log_info "Настройка Backend..."
docker exec fms_backend php artisan key:generate
docker exec fms_backend php artisan migrate --force
docker exec fms_backend php artisan config:cache
docker exec fms_backend php artisan route:cache

# Этап 7: Проверка установки
log_info "Проверка установки..."
docker-compose -f docker-compose-domain.yml ps

# Проверка API
log_info "Проверка API..."
if curl -s "http://localhost:8000/api/cultures" > /dev/null; then
    log_info "✅ API работает корректно!"
else
    log_warn "⚠️ API может быть недоступен. Проверьте логи:"
    docker-compose -f docker-compose-domain.yml logs backend
fi

# Вывод информации
echo
log_info "=== Установка завершена! ==="
echo
echo "Доступ к системе:"
echo "🌐 Frontend: https://$DOMAIN"
echo "🔧 Backend API: https://$DOMAIN/api"
echo "🗄️ База данных: localhost:3306"
echo
echo "Управление:"
echo "📊 Статус: docker-compose -f docker-compose-domain.yml ps"
echo "📋 Логи: docker-compose -f docker-compose-domain.yml logs -f"
echo "🛑 Остановка: docker-compose -f docker-compose-domain.yml down"
echo "🔄 Перезапуск: docker-compose -f docker-compose-domain.yml restart"
echo
echo "База данных:"
echo "📊 База: $DB_NAME"
echo "👤 Пользователь: $DB_USER"
echo "🔑 Пароль: $DB_PASSWORD"
echo "🔑 Root пароль: $DB_ROOT_PASSWORD"
echo
echo "Следующие шаги:"
echo "1. Настройте nginx конфигурацию в FastPanel"
echo "2. Установите SSL сертификат через FastPanel"
echo "3. Откройте https://$DOMAIN и протестируйте систему"
echo
log_info "Система готова к использованию!" 