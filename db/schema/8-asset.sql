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

-- consumable  
CREATE TABLE IF NOT EXISTS consumable (
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

-- example of a property: "color" = "red" or "size" = "large"	
CREATE TABLE IF NOT EXISTS resource_property (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    asset_id INT DEFAULT NULL,
    consumable_id INT DEFAULT NULL,
    property VARCHAR(256) DEFAULT NULL,
    value VARCHAR(256) DEFAULT NULL,
    FOREIGN KEY (asset_id) REFERENCES asset(id),
    FOREIGN KEY (consumable_id) REFERENCES consumable(id)
);

-- consumable Supplier
CREATE TABLE IF NOT EXISTS supply (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    asset_id INT DEFAULT NULL,
    consumable_id INT DEFAULT NULL,
    supplier_id INT DEFAULT NULL,
    person_id INT DEFAULT NULL,
    order_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    delivery_date DATE DEFAULT NULL,
    order_id VARCHAR(256) DEFAULT NULL,
    order_amount INT DEFAULT 0,
    created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (asset_id) REFERENCES asset(id),
    FOREIGN KEY (consumable_id) REFERENCES consumable(id),
    FOREIGN KEY (supplier_id) REFERENCES supplier(id),
    FOREIGN KEY (person_id) REFERENCES person(id)
);

-- consumable Allocation
CREATE TABLE IF NOT EXISTS resource_allocation (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    requested BOOLEAN NOT NULL DEFAULT FALSE,
    approved BOOLEAN NOT NULL DEFAULT FALSE,
    allocated BOOLEAN NOT NULL DEFAULT TRUE,
    asset_id INT DEFAULT NULL,
    consumable_id INT DEFAULT NULL,
    organization_id INT DEFAULT NULL,
    person_id INT DEFAULT NULL,
    quantity INT NOT NULL DEFAULT 0,
    start_date DATE NOT NULL,
    end_date DATE DEFAULT NULL,
    created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (asset_id) REFERENCES asset(id),
    FOREIGN KEY (consumable_id) REFERENCES consumable(id),
    FOREIGN KEY (organization_id) REFERENCES organization(id),
    FOREIGN KEY (person_id) REFERENCES person(id)
);

-- consumable Inventory
CREATE TABLE IF NOT EXISTS inventory (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    avinya_type_id INT DEFAULT NULL,
    asset_id INT DEFAULT NULL,
    consumable_id INT DEFAULT NULL,
    organization_id INT DEFAULT NULL,
    person_id INT DEFAULT NULL,
    quantity INT NOT NULL DEFAULT 0,
    quantity_in INT NOT NULL DEFAULT 0,
    quantity_out INT NOT NULL DEFAULT 0,
    created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (avinya_type_id) REFERENCES avinya_type(id),
    FOREIGN KEY (asset_id) REFERENCES asset(id),
    FOREIGN KEY (consumable_id) REFERENCES consumable(id),
    FOREIGN KEY (organization_id) REFERENCES organization(id),
    FOREIGN KEY (person_id) REFERENCES person(id)
);

DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS `getAssetByAvinyaType`(at_id int) 
    DETERMINISTIC
BEGIN
    DECLARE count INT DEFAULT 0;
    DECLARE firstId INT;
    SET count = (SELECT COUNT(*)
                 FROM asset
                 WHERE avinya_type_id = at_id 
                 AND asset.id NOT IN (
                    SELECT asset_id
                    FROM resource_allocation
                    WHERE allocated = true
                 ));
    IF count > 0 THEN
        SET firstId = (SELECT asset.id
                       FROM asset
                       WHERE avinya_type_id = at_id
                       AND asset.id NOT IN (
                            SELECT asset_id
                            FROM resource_allocation
                            WHERE allocated = true
                       )
                       ORDER BY asset.id ASC
                       LIMIT 1);
        SELECT asset.*
        FROM asset
        WHERE id = firstId;
    ELSE
        SELECT count;
    END IF;
END$$
DELIMITER ;

CREATE VIEW `avinya_types_for_asset` AS
    SELECT 
        `avinya_type`.`id` AS `id`,
        `avinya_type`.`active` AS `active`,
        `avinya_type`.`global_type` AS `global_type`,
        `avinya_type`.`name` AS `name`,
        `avinya_type`.`description` AS `description`,
        `avinya_type`.`foundation_type` AS `foundation_type`,
        `avinya_type`.`focus` AS `focus`,
        `avinya_type`.`level` AS `level`
    FROM
        (`asset`
        JOIN `avinya_type` ON ((`asset`.`avinya_type_id` = `avinya_type`.`id`)))
    GROUP BY `asset`.`avinya_type_id`;






















































