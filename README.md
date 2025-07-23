# 🌱 Система управления огородом (FMS)

Цифровая система управления огородом на PHP (Laravel) + Vue.js с интеграцией погоды и AI-рекомендаций.

## 🚀 Возможности

- **Каталог культур** с описанием сортов и сроками посадки/сбора
- **Каталог препаратов** для обработки растений
- **Планы выращивания** для каждой культуры
- **Каталог полей** с выбором координат на карте
- **Календарь действий** для каждого поля с отметками выполнения
- **Интеграция погоды** по координатам полей
- **Уведомления** о погодных рисках
- **AI-рекомендации** через Deepseek API
- **Мобильная адаптация** для работы с телефона

## 🛠 Технологии

### Backend
- **PHP 8.1** с Laravel 10
- **MySQL 8.0** база данных
- **REST API** для frontend
- **OpenWeatherMap API** для погоды
- **Deepseek API** для рекомендаций

### Frontend
- **Vue.js 3** с Composition API
- **Vue Router** для навигации
- **Leaflet** для карт
- **Адаптивный дизайн** для мобильных устройств

### Инфраструктура
- **Docker** для контейнеризации
- **Nginx** для веб-сервера
- **FastPanel** для управления сервером
- **GitHub Container Registry** для Docker образов

## 📦 Установка

### Быстрый старт с Docker

```bash
# Клонирование репозитория
git clone https://github.com/Aleksandr-Polskoy/fms.git
cd fms

# Запуск с доменом
chmod +x start-domain.sh
./start-domain.sh

# Или запуск по IP
chmod +x start.sh
./start.sh
```

### Использование готовых Docker образов

```bash
# Создайте .env файл
cp env.example .env

# Запустите с production образами
docker-compose -f docker-compose-production.yml up -d
```

### Установка на сервер с FastPanel

Следуйте инструкции в [FASTPANEL_DOMAIN_SETUP.md](FASTPANEL_DOMAIN_SETUP.md)

## 🐳 Docker образы

Система автоматически собирает Docker образы в GitHub Container Registry:

### Доступные образы:
- **Backend**: `ghcr.io/aleksandr-polskoy/fms/backend:latest`
- **Frontend**: `ghcr.io/aleksandr-polskoy/fms/frontend:latest`
- **MySQL**: `ghcr.io/aleksandr-polskoy/fms/mysql:latest`

### Использование образов:
```bash
# Скачать образ
docker pull ghcr.io/aleksandr-polskoy/fms/backend:latest

# Запустить контейнер
docker run -d ghcr.io/aleksandr-polskoy/fms/backend:latest
```

## 🌐 Доступ к системе

После установки система будет доступна:
- **Frontend**: https://ваш-домен.com (или http://ваш_ip)
- **Backend API**: https://ваш-домен.com/api (или http://ваш_ip:8000)

## 📊 База данных

- **База данных**: `fms_db`
- **Пользователь**: `fms_user`
- **Пароль**: `fms_password`

## 🔧 Управление

```bash
# Статус контейнеров
docker-compose -f docker-compose-domain.yml ps

# Просмотр логов
docker-compose -f docker-compose-domain.yml logs -f

# Перезапуск
docker-compose -f docker-compose-domain.yml restart

# Остановка
docker-compose -f docker-compose-domain.yml down
```

## 📁 Структура проекта

```
fms/
├── backend/                 # Laravel API
│   ├── app/
│   │   ├── Http/Controllers/
│   │   └── Models/
│   ├── database/migrations/
│   └── routes/api.php
├── frontend/               # Vue.js приложение
│   ├── src/
│   │   ├── components/
│   │   ├── views/
│   │   └── router/
│   └── public/
├── nginx/                  # Nginx конфигурации
├── mysql/                  # MySQL Dockerfile
├── .github/workflows/      # GitHub Actions
├── docker-compose.yml      # Docker для IP
├── docker-compose-domain.yml # Docker для домена
├── docker-compose-production.yml # Production образы
├── dump.sql               # Структура БД
└── README.md              # Документация
```

## 🔑 API ключи (опционально)

Для полной функциональности добавьте в `.env`:

```env
OPENWEATHER_API_KEY=ваш_ключ_openweather
DEEPSEEK_API_KEY=ваш_ключ_deepseek
```

## 📱 Мобильная адаптация

Система полностью адаптирована для работы на мобильных устройствах:
- Адаптивный дизайн
- Touch-friendly интерфейс
- Оптимизированные формы

## 🚨 Уведомления

Система поддерживает настраиваемые уведомления:
- Погодные риски для культур
- Перенос работ из-за дождя
- Рекомендации по уходу

## 🤖 AI-рекомендации

Интеграция с Deepseek API для получения рекомендаций на основе:
- Текущей погоды
- Состояния культур
- Предыдущих действий
- Примененных препаратов

## 📈 Развитие проекта

- [ ] Добавление новых культур
- [ ] Расширение погодных уведомлений
- [ ] Интеграция с IoT датчиками
- [ ] Экспорт данных
- [ ] Мультипользовательский режим

## 📞 Поддержка

При возникновении проблем:
1. Проверьте логи: `docker-compose logs`
2. Убедитесь в правильности конфигурации nginx
3. Проверьте доступность API ключей

## 📄 Лицензия

MIT License - используйте свободно для личных и коммерческих проектов.

---

**Создано с ❤️ для эффективного управления огородом** 