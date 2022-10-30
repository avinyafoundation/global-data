USE avinya_db;

-- Person
CREATE TABLE IF NOT EXISTS person (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    preferred_name VARCHAR(512) NOT NULL,
    full_name VARCHAR(1024) DEFAULT NULL,
    date_of_birth DATE DEFAULT NULL,
    sex ENUM ("Male", "Female", "Not Specified") DEFAULT "Not Specified",
    asgardeo_id VARCHAR(255) DEFAULT NULL,
    permanent_address_id INT DEFAULT NULL,
    mailing_address_id INT DEFAULT NULL,
    phone BIGINT DEFAULT 0,
    organization_id INT DEFAULT NULL,
    avinya_type_id INT DEFAULT NULL,
    notes VARCHAR(1024) DEFAULT NULL,
    nic_no VARCHAR(30) DEFAULT NULL,
    passport_no VARCHAR(30) DEFAULT NULL,
    id_no VARCHAR(30) DEFAULT NULL,
    email VARCHAR(254) DEFAULT NULL,
    FOREIGN KEY (permanent_address_id) REFERENCES address(id),
    FOREIGN KEY (mailing_address_id) REFERENCES address(id),
    FOREIGN KEY (organization_id) REFERENCES organization(id),
    FOREIGN KEY (avinya_type_id) REFERENCES avinya_type(id)
);
