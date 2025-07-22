FROM node:18-alpine

# Установка рабочей директории
WORKDIR /app

# Копирование package файлов
COPY package*.json ./

# Установка зависимостей
RUN npm install

# Копирование исходного кода
COPY . .

# Сборка проекта
RUN npm run build

# Установка nginx для раздачи статических файлов
FROM nginx:alpine

# Копирование собранных файлов
COPY --from=0 /app/dist /usr/share/nginx/html

# Копирование nginx конфигурации
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Открытие порта
EXPOSE 80

# Запуск nginx
CMD ["nginx", "-g", "daemon off;"] 