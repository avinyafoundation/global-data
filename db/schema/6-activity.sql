USE avinya_db;

-- Activity
CREATE TABLE IF NOT EXISTS activity (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(256) NOT NULL,
    description VARCHAR(1024) DEFAULT NULL,
    avinya_type_id INT DEFAULT NULL,
    notes TEXT DEFAULT NULL,
    created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (avinya_type_id) REFERENCES avinya_type(id)
);

-- Activity Sequence Plan 
CREATE TABLE IF NOT EXISTS activity_sequence_plan (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    activity_id INT NOT NULL,
    sequence_number INT NOT NULL DEFAULT 0,
    timeslot_number INT NOT NULL,
    person_id INT DEFAULT NULL,
    organization_id INT DEFAULT NULL,
    created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (activity_id) REFERENCES activity(id),
    FOREIGN KEY (person_id) REFERENCES person(id),
    FOREIGN KEY (organization_id) REFERENCES organization(id)
);

-- Parent Child Activity
CREATE TABLE IF NOT EXISTS parent_child_activity (
    child_activity_id INT NOT NULL,
    parent_activity_id INT NOT NULL,
    FOREIGN KEY (child_activity_id) REFERENCES activity(id),
    FOREIGN KEY (parent_activity_id) REFERENCES activity(id),
    CONSTRAINT pk_parent_child_activity PRIMARY KEY (child_activity_id, parent_activity_id)
);

-- Place
-- We will live with both address and place for now
-- Note that the place has more information than the address
CREATE TABLE IF NOT EXISTS place (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    olc VARCHAR(15) NOT NULL, -- Open Location Code
    city_id INT DEFAULT NULL,
    name VARCHAR(256) NOT NULL,
    display_name VARCHAR(256) NOT NULL,
    street_address VARCHAR(256) DEFAULT NULL,
    suite VARCHAR(256) DEFAULT NULL,
    level INT DEFAULT 0,
    address_id INT DEFAULT NULL, -- Address should be OLC, but for now we'll use the address_id too (becuase we have addresses in the DB)
    description VARCHAR(1024) DEFAULT NULL,
    notes TEXT DEFAULT NULL,
    created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (city_id) REFERENCES city(id),
    FOREIGN KEY (address_id) REFERENCES address(id)
);

-- Parent Child Place
-- Facility is a place that has children places
CREATE TABLE IF NOT EXISTS parent_child_place (
    child_place_id INT NOT NULL,
    parent_place_id INT NOT NULL,
    FOREIGN KEY (child_place_id) REFERENCES place(id),
    FOREIGN KEY (parent_place_id) REFERENCES place(id),
    CONSTRAINT pk_parent_child_place PRIMARY KEY (child_place_id, parent_place_id)
);

-- Activity Instance
CREATE TABLE IF NOT EXISTS activity_instance (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    activity_id INT NOT NULL,
    name VARCHAR(256) NOT NULL,
    place_id INT DEFAULT NULL,
    daily_sequence INT DEFAULT 0,
    weekly_sequence INT DEFAULT 0,
    monthly_sequence INT DEFAULT 0,
    description VARCHAR(1024) DEFAULT NULL,
    notes TEXT DEFAULT NULL,
    organization_id INT DEFAULT NULL,
    start_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    end_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (activity_id) REFERENCES activity(id),
    FOREIGN KEY (organization_id) REFERENCES organization(id),
    FOREIGN KEY (place_id) REFERENCES place(id)
);

-- Activity Participant
CREATE TABLE IF NOT EXISTS activity_participant (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    activity_instance_id INT NOT NULL,
    person_id INT DEFAULT NULL,
    organization_id INT DEFAULT NULL,
    start_date DATE DEFAULT NULL,
    end_date DATE DEFAULT NULL,
    role VARCHAR(256) DEFAULT NULL,
    notes TEXT DEFAULT NULL,
    created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (activity_instance_id) REFERENCES activity_instance(id),
    FOREIGN KEY (person_id) REFERENCES person(id),
    FOREIGN KEY (organization_id) REFERENCES organization(id)
);

-- Activity Participant Attendance
CREATE TABLE IF NOT EXISTS activity_participant_attendance (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    person_id INT NOT NULL,
    activity_instance_id INT NOT NULL,
    sign_in_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    sign_out_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    in_marked_by VARCHAR(254) DEFAULT 'system@avinya.edu.lk',
    out_marked_by VARCHAR(254) DEFAULT 'system@avinya.edu.lk',
    created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (activity_instance_id) REFERENCES activity_instance(id),
    FOREIGN KEY (person_id) REFERENCES person(id)
);

-- Activity Evaluation Criteria
CREATE TABLE IF NOT EXISTS activity_evaluation_criteria (
    activity_id INT NOT NULL,
    evaluation_criteria_id INT NOT NULL,
    FOREIGN KEY (activity_id) REFERENCES activity(id),
    FOREIGN KEY (evaluation_criteria_id) REFERENCES evaluation_criteria(id),
    CONSTRAINT pk_activity_evaluation_criteria PRIMARY KEY (activity_id, evaluation_criteria_id)
);

-- Activity Instance Evaluation Criteria
CREATE TABLE IF NOT EXISTS activity_instance_evaluation_criteria (
    activity_instance_id INT NOT NULL,
    evaluation_criteria_id INT NOT NULL,
    FOREIGN KEY (activity_instance_id) REFERENCES activity_instance(id),
    FOREIGN KEY (evaluation_criteria_id) REFERENCES evaluation_criteria(id),
    CONSTRAINT pk_activity_instance_evaluation_criteria PRIMARY KEY (evaluation_criteria_id, activity_instance_id)
);

