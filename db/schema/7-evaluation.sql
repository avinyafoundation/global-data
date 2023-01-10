USE avinya_db;

-- Evaluation 
CREATE TABLE IF NOT EXISTS evaluation (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    evaluatee_id INT DEFAULT NULL,  -- select vacancy for application and then select evaluation criterial for vacancy, and for each of those criteria grade the applicant 
    evaluator_id INT DEFAULT NULL,
    evaluation_criteria_id INT NOT NULL,
    activity_instance_id INT DEFAULT NULL,
    response VARCHAR(1024) DEFAULT NULL,
    notes VARCHAR(1024) DEFAULT NULL,
    grade INT NOT NULL DEFAULT 0,
    updated TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (evaluatee_id) REFERENCES person(id),
    FOREIGN KEY (evaluator_id) REFERENCES person(id),
    FOREIGN KEY (evaluation_criteria_id) REFERENCES evaluation_criteria(id),
    FOREIGN KEY (activity_instance_id) REFERENCES activity_instance(id)
);

CREATE TABLE IF NOT EXISTS evaluation_metadata (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    evaluation_id INT NOT NULL,
    location VARCHAR(1024) DEFAULT NULL,
    on_date_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    level INT DEFAULT 0,
    meta_type VARCHAR(512) DEFAULT NULL,
    focus VARCHAR(512) DEFAULT NULL,
    status VARCHAR(100) DEFAULT NULL,
    metadata TEXT DEFAULT NULL,
    FOREIGN KEY (evaluation_id) REFERENCES evaluation(id)
);


CREATE TABLE IF NOT EXISTS parent_child_evaluation (
    child_evaluation_id INT NOT NULL,
    parent_evaluation_id INT NOT NULL,
    FOREIGN KEY (child_evaluation_id) REFERENCES evaluation(id),
    FOREIGN KEY (parent_evaluation_id) REFERENCES evaluation(id),
    CONSTRAINT pk_parent_child_evaluation PRIMARY KEY (child_evaluation_id, parent_evaluation_id)
);

-- Education Experience
CREATE TABLE IF NOT EXISTS education_experience (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    person_id INT NOT NULL,
    school VARCHAR(512) NOT NULL,
    start_date DATE DEFAULT NULL,
    end_date DATE DEFAULT NULL,
    FOREIGN KEY (person_id) REFERENCES person(id)
);

CREATE TABLE IF NOT EXISTS education_experience_evaluation (
    education_experience_id INT NOT NULL,
    evaluation_id INT NOT NULL,
    FOREIGN KEY (education_experience_id) REFERENCES education_experience(id),
    FOREIGN KEY (evaluation_id) REFERENCES evaluation(id),
    CONSTRAINT pk_education_experience_evaluation PRIMARY KEY (education_experience_id, evaluation_id)
);

CREATE TABLE IF NOT EXISTS work_experience (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    person_id INT NOT NULL,
    organization VARCHAR(512) NOT NULL,
    start_date DATE DEFAULT NULL,
    end_date DATE DEFAULT NULL,
    FOREIGN KEY (person_id) REFERENCES person(id)
);

CREATE TABLE IF NOT EXISTS work_experience_evaluation (
    work_experience_id INT NOT NULL,
    evaluation_id INT NOT NULL,
    FOREIGN KEY (work_experience_id) REFERENCES work_experience(id),
    FOREIGN KEY (evaluation_id) REFERENCES evaluation(id),
    CONSTRAINT pk_education_experience_evaluation PRIMARY KEY (work_experience_id, evaluation_id)
);
