FROM mysql:8.0

# Копирование SQL файла для инициализации базы данных
COPY ../dump.sql /docker-entrypoint-initdb.d/

# Настройка переменных окружения
ENV MYSQL_ROOT_PASSWORD=root_password
ENV MYSQL_DATABASE=fms_db
ENV MYSQL_USER=fms_user
ENV MYSQL_PASSWORD=fms_password

# Открытие порта
EXPOSE 3306

# Использование стандартной команды MySQL
CMD ["mysqld"] 