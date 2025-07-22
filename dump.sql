-- Дамп структуры БД для цифровой системы огорода

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role ENUM('admin','agronomist','worker','guest') DEFAULT 'guest',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE cultures (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    photo VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE varieties (
    id INT AUTO_INCREMENT PRIMARY KEY,
    culture_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    sowing_period VARCHAR(50),
    harvest_period VARCHAR(50),
    photo VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (culture_id) REFERENCES cultures(id) ON DELETE CASCADE
);

CREATE TABLE preparations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    photo VARCHAR(255),
    usage TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE fields (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    area DECIMAL(10,2),
    coordinates VARCHAR(255),
    photo VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE plans (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    culture_id INT NOT NULL,
    variety_id INT,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (culture_id) REFERENCES cultures(id) ON DELETE CASCADE,
    FOREIGN KEY (variety_id) REFERENCES varieties(id) ON DELETE SET NULL
);

CREATE TABLE plan_steps (
    id INT AUTO_INCREMENT PRIMARY KEY,
    plan_id INT NOT NULL,
    action VARCHAR(100) NOT NULL,
    description TEXT,
    photo VARCHAR(255),
    preparation_id INT,
    weather_conditions TEXT,
    step_order INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (plan_id) REFERENCES plans(id) ON DELETE CASCADE,
    FOREIGN KEY (preparation_id) REFERENCES preparations(id) ON DELETE SET NULL
);

CREATE TABLE field_plans (
    id INT AUTO_INCREMENT PRIMARY KEY,
    field_id INT NOT NULL,
    plan_id INT NOT NULL,
    start_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (field_id) REFERENCES fields(id) ON DELETE CASCADE,
    FOREIGN KEY (plan_id) REFERENCES plans(id) ON DELETE CASCADE
);

CREATE TABLE field_actions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    field_plan_id INT NOT NULL,
    plan_step_id INT NOT NULL,
    status ENUM('pending','done') DEFAULT 'pending',
    actual_date DATE,
    photo_report VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (field_plan_id) REFERENCES field_plans(id) ON DELETE CASCADE,
    FOREIGN KEY (plan_step_id) REFERENCES plan_steps(id) ON DELETE CASCADE
);

CREATE TABLE weather_data (
    id INT AUTO_INCREMENT PRIMARY KEY,
    field_id INT NOT NULL,
    date DATE NOT NULL,
    temperature DECIMAL(5,2),
    humidity DECIMAL(5,2),
    precipitation DECIMAL(5,2),
    weather_icon VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (field_id) REFERENCES fields(id) ON DELETE CASCADE
);

CREATE TABLE notification_rules (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    culture_id INT,
    action VARCHAR(100),
    weather_condition TEXT,
    message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (culture_id) REFERENCES cultures(id) ON DELETE SET NULL
);

CREATE TABLE notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    field_id INT NOT NULL,
    date DATE NOT NULL,
    rule_id INT,
    status ENUM('active','read','archived') DEFAULT 'active',
    message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (field_id) REFERENCES fields(id) ON DELETE CASCADE,
    FOREIGN KEY (rule_id) REFERENCES notification_rules(id) ON DELETE SET NULL
); 