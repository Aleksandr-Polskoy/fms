#!/bin/bash

# Скрипт для создания Self-Signed SSL сертификата

echo "=== Создание Self-Signed SSL сертификата ==="

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

DOMAIN="fms.devdemo.ru"
SSL_DIR="/opt/fms/ssl"

log_info "Создание папки для сертификатов..."
mkdir -p $SSL_DIR

log_info "Создание Self-Signed сертификата..."
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout $SSL_DIR/private.key \
  -out $SSL_DIR/certificate.crt \
  -subj "/C=RU/ST=Moscow/L=Moscow/O=FMS/OU=IT/CN=$DOMAIN"

log_info "Установка прав доступа..."
chmod 600 $SSL_DIR/private.key
chmod 644 $SSL_DIR/certificate.crt

log_info "Проверка созданных файлов..."
ls -la $SSL_DIR/

echo ""
log_info "✅ SSL сертификат создан!"
echo ""
echo "📋 Файлы сертификата:"
echo "🔑 Приватный ключ: $SSL_DIR/private.key"
echo "📜 Сертификат: $SSL_DIR/certificate.crt"
echo ""
echo "📋 Инструкция для FastPanel:"
echo "1. Войдите в FastPanel"
echo "2. Перейдите в 'SSL сертификаты'"
echo "3. Выберите сайт '$DOMAIN'"
echo "4. Выберите 'Загрузить сертификат'"
echo "5. Загрузите файлы:"
echo "   - Сертификат: $SSL_DIR/certificate.crt"
echo "   - Приватный ключ: $SSL_DIR/private.key"
echo ""
log_warn "⚠️ Self-Signed сертификат будет показывать предупреждение в браузере"
log_warn "⚠️ Для продакшена рекомендуется использовать Cloudflare или DNS Challenge" 