-- Assets 
CREATE TABLE IF NOT EXISTS asset (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(256) NOT NULL,
    manufacturer VARCHAR(256) DEFAULT NULL,
    model VARCHAR(256) DEFAULT NULL,
    serial_number VARCHAR(256) DEFAULT NULL,
    registration_number VARCHAR(256) DEFAULT NULL,
    description TEXT DEFAULT NULL,
    avinya_type_id INT NOT NULL,
    created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (avinya_type_id) REFERENCES avinya_type(id)
);
 
-- Asset Allocation
CREATE TABLE IF NOT EXISTS asset_allocation (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    asset_id INT NOT NULL,
    organization_id INT DEFAULT NULL,
    person_id INT DEFAULT NULL,
    start_date DATE NOT NULL,
    end_date DATE DEFAULT NULL,
    created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (asset_id) REFERENCES asset(id),
    FOREIGN KEY (organization_id) REFERENCES organization(id),
    FOREIGN KEY (person_id) REFERENCES person(id)
);