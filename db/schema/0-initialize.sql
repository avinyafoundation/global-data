CREATE DATABASE IF NOT EXISTS avinya_db;

USE avinya_db;

-- Configuring Unicode
ALTER DATABASE avinya_db
CHARACTER SET = utf8mb4
COLLATE = utf8mb4_unicode_ci;

-- Province
CREATE TABLE IF NOT EXISTS province (
    id INT NOT NULL PRIMARY KEY,
    name_en VARCHAR(255) NOT NULL,
    name_ta VARCHAR(255),
    name_si VARCHAR(255)
);


-- District
CREATE TABLE IF NOT EXISTS district (
    id INT NOT NULL PRIMARY KEY,
    province_id INT NOT NULL,
    name_en VARCHAR(255) NOT NULL,
    name_ta VARCHAR(255),
    name_si VARCHAR(255),
    FOREIGN KEY (province_id) REFERENCES province(id)
);

-- City
CREATE TABLE IF NOT EXISTS city (
    id INT NOT NULL PRIMARY KEY,
    district_id INT NOT NULL,
    name_en VARCHAR(255) NOT NULL,
    name_ta VARCHAR(255),
    name_si VARCHAR(255),
    suburb_name_en VARCHAR(255),
    suburb_name_ta VARCHAR(255),
    suburb_name_si VARCHAR(255),
    postcode VARCHAR(10),
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    FOREIGN KEY (district_id) REFERENCES district(id)
);
