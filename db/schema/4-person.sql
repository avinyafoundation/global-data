USE avinya_db;

-- Person
CREATE TABLE IF NOT EXISTS person (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    preferred_name VARCHAR(512) NOT NULL,
    full_name VARCHAR(1024) DEFAULT NULL,
    date_of_birth DATE DEFAULT NULL,
    sex ENUM ("Male", "Female", "Not Specified") DEFAULT "Not Specified",
    asgardeo_id VARCHAR(255) DEFAULT NULL,
    jwt_sub_id VARCHAR(255) DEFAULT NULL,
    jwt_email VARCHAR(254) DEFAULT NULL,
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
    created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    street_address VARCHAR(255) DEFAULT NULL,
    digital_id VARCHAR(254) DEFAULT NULL,
    avinya_phone BIGINT DEFAULT 0,
    bank_name VARCHAR(254) DEFAULT NULL,
    bank_account_number VARCHAR(254) DEFAULT NULL,
    bank_account_name VARCHAR(254) DEFAULT NULL,
    academy_org_id INT DEFAULT NULL,
    FOREIGN KEY (permanent_address_id) REFERENCES address(id),
    FOREIGN KEY (mailing_address_id) REFERENCES address(id),
    FOREIGN KEY (organization_id) REFERENCES organization(id),
    FOREIGN KEY (avinya_type_id) REFERENCES avinya_type(id)
);

-- Person Avinya Type Transision History
CREATE TABLE IF NOT EXISTS person_avinya_type_transition_history (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    person_id INT NOT NULL,
    previous_avinya_type_id INT NOT NULL,
    new_avinya_type_id INT NOT NULL,
    transition_date DATE NOT NULL,
    created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (person_id) REFERENCES person(id),
    FOREIGN KEY (previous_avinya_type_id) REFERENCES avinya_type(id),
    FOREIGN KEY (new_avinya_type_id) REFERENCES avinya_type(id)
);

CREATE TABLE IF NOT EXISTS person_organization_transition_history (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    person_id INT NOT NULL,
    previous_organization_id INT NOT NULL,
    new_organization_id INT NOT NULL,
    transition_date DATE NOT NULL,
    created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (person_id) REFERENCES person(id),
    FOREIGN KEY (previous_organization_id) REFERENCES organization(id),
    FOREIGN KEY (new_organization_id) REFERENCES organization(id)
);

CREATE TABLE IF NOT EXISTS parent_child_student(
    child_student_id INT NOT NULL,
    parent_student_id INT NOT NULL,
    FOREIGN KEY (child_student_id) REFERENCES person(id),
    FOREIGN KEY (parent_student_id) REFERENCES person(id),
    CONSTRAINT pk_parent_child_student PRIMARY KEY (child_student_id, parent_student_id)
);