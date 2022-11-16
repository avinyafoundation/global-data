USE avinya_db;

CREATE TABLE IF NOT EXISTS avinya_type (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    active BOOLEAN NOT NULL,
    global_type VARCHAR(100) default "Unknown" NOT NULL,
    name VARCHAR(255),
    foundation_type VARCHAR(100),
    focus VARCHAR(100),
    level INT
);
