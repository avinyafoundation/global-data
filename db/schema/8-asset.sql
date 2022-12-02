USE avinya_db;

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

-- Asset Property
-- example of a property: "color" = "red" or "size" = "large"	
CREATE TABLE IF NOT EXISTS asset_property (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    asset_id INT NOT NULL,
    property VARCHAR(256) DEFAULT NULL,
    value VARCHAR(256) DEFAULT NULL,
    FOREIGN KEY (asset_id) REFERENCES asset(id)
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

-- Supplier 
CREATE TABLE IF NOT EXISTS supplier (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(256) NOT NULL,
    description TEXT DEFAULT NULL,
    phone BIGINT DEFAULT NULL,
    email VARCHAR(256) DEFAULT NULL,
    address_id INT DEFAULT NULL,
    created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Product  
CREATE TABLE IF NOT EXISTS product (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(256) NOT NULL,
    description TEXT DEFAULT NULL,
    avinya_type_id INT NOT NULL,
    manufacturer VARCHAR(256) DEFAULT NULL,
    model VARCHAR(256) DEFAULT NULL,
    serial_number VARCHAR(256) DEFAULT NULL,
    created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (avinya_type_id) REFERENCES avinya_type(id)
);

CREATE TABLE IF NOT EXISTS product_property (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    property VARCHAR(256) DEFAULT NULL,
    value VARCHAR(256) DEFAULT NULL,
    FOREIGN KEY (product_id) REFERENCES product(id)
);

-- Product Supplier
CREATE TABLE IF NOT EXISTS product_supplier (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    supplier_id INT DEFAULT NULL,
    person_id INT DEFAULT NULL,
    order_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    delivery_date DATE DEFAULT NULL,
    order_id VARCHAR(256) DEFAULT NULL,
    order_amount INT DEFAULT 0,
    created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES product(id),
    FOREIGN KEY (supplier_id) REFERENCES supplier(id),
    FOREIGN KEY (person_id) REFERENCES person(id)
);

-- Product Allocation
CREATE TABLE IF NOT EXISTS product_allocation (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    organization_id INT DEFAULT NULL,
    person_id INT DEFAULT NULL,
    quantity INT NOT NULL DEFAULT 0,
    start_date DATE NOT NULL,
    end_date DATE DEFAULT NULL,
    created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES product(id),
    FOREIGN KEY (organization_id) REFERENCES organization(id),
    FOREIGN KEY (person_id) REFERENCES person(id)
);

-- Product Inventory
CREATE TABLE IF NOT EXISTS product_inventory (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    organization_id INT DEFAULT NULL,
    person_id INT DEFAULT NULL,
    quantity INT NOT NULL DEFAULT 0,
    quantity_in INT NOT NULL DEFAULT 0,
    quantity_out INT NOT NULL DEFAULT 0,
    created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES product(id),
    FOREIGN KEY (organization_id) REFERENCES organization(id),
    FOREIGN KEY (person_id) REFERENCES person(id)
);

-- Service 
CREATE TABLE IF NOT EXISTS service (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(256) NOT NULL,
    description TEXT DEFAULT NULL,
    avinya_type_id INT NOT NULL,
    created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (avinya_type_id) REFERENCES avinya_type(id)
);

CREATE TABLE IF NOT EXISTS service_property (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    service_id INT NOT NULL,
    property VARCHAR(256) DEFAULT NULL,
    value VARCHAR(256) DEFAULT NULL,
    FOREIGN KEY (service_id) REFERENCES service(id)
);

-- Service Supplier
CREATE TABLE IF NOT EXISTS service_supplier (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    service_id INT NOT NULL,
    supplier_id INT DEFAULT NULL,
    person_id INT DEFAULT NULL,
    order_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    delivery_date DATE DEFAULT NULL,
    order_id VARCHAR(256) DEFAULT NULL,
    order_amount INT DEFAULT 0,
    created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (service_id) REFERENCES service(id),
    FOREIGN KEY (supplier_id) REFERENCES supplier(id),
    FOREIGN KEY (person_id) REFERENCES person(id)
);

-- Service Allocation
CREATE TABLE IF NOT EXISTS service_allocation (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    service_id INT NOT NULL,
    organization_id INT DEFAULT NULL,
    person_id INT DEFAULT NULL,
    quantity INT NOT NULL DEFAULT 0,
    start_date DATE NOT NULL,
    end_date DATE DEFAULT NULL,
    created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (service_id) REFERENCES service(id),
    FOREIGN KEY (organization_id) REFERENCES organization(id),
    FOREIGN KEY (person_id) REFERENCES person(id)
);

-- Service Inventory
CREATE TABLE IF NOT EXISTS service_inventory (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    service_id INT NOT NULL,
    organization_id INT DEFAULT NULL,
    person_id INT DEFAULT NULL,
    quantity INT NOT NULL DEFAULT 0,
    quantity_in INT NOT NULL DEFAULT 0,
    quantity_out INT NOT NULL DEFAULT 0,
    created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (service_id) REFERENCES service(id),
    FOREIGN KEY (organization_id) REFERENCES organization(id),
    FOREIGN KEY (person_id) REFERENCES person(id)
);
