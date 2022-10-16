USE avinya_db;

-- Evaluation Cycle
CREATE TABLE IF NOT EXISTS evaluation_cycle (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(513) NOT NULL,
    description VARCHAR(1024) DEFAULT NULL,
    start_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    end_date DATE DEFAULT NULL
);

-- Evaluation Criteria
CREATE TABLE IF NOT EXISTS evaluation_criteria (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    prompt VARCHAR(1024) NOT NULL,
    description VARCHAR(1024) DEFAULT NULL,
    expected_answer VARCHAR(1024) DEFAULT NULL,
    evalualtion_type VARCHAR(100) DEFAULT 'Essay', -- Essay, Multiple Choice, True/False, Rating
    difficulty VARCHAR(100) DEFAULT 'Medium', -- Easy, Medium, Hard
    rating_out_of INT DEFAULT 5
);

-- Evaluation Criteria Answer Options
CREATE TABLE IF NOT EXISTS evaluation_criteria_answer_option (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    evaluation_criteria_id INT NOT NULL,
    answer VARCHAR(1024) NOT NULL,
    expected_answer BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (evaluation_criteria_id) REFERENCES evaluation_criteria(id)
);

-- Vacancy 
CREATE TABLE IF NOT EXISTS vacancy (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(513) NOT NULL,
    description VARCHAR(1024) DEFAULT NULL,
    organization_id INT DEFAULT NULL,
    avinya_type_id INT DEFAULT NULL,
    evaluation_cycle_id INT DEFAULT NULL,
    head_count INT NOT NULL DEFAULT 1, -- count is a SQL keyword so we can't use it
    FOREIGN KEY (organization_id) REFERENCES organization(id),
    FOREIGN KEY (avinya_type_id) REFERENCES avinya_type(id),
    FOREIGN KEY (evaluation_cycle_id) REFERENCES evaluation_cycle(id)
);

-- Vacancy Evaluation Criteria
CREATE TABLE IF NOT EXISTS vacancy_evaluation_criteria (
    vacancy_id INT NOT NULL,
    evaluation_criteria_id INT NOT NULL,
    FOREIGN KEY (vacancy_id) REFERENCES vacancy(id),
    FOREIGN KEY (evaluation_criteria_id) REFERENCES evaluation_criteria(id),
    CONSTRAINT pk_vacancy_evaluation_criteria PRIMARY KEY (evaluation_criteria_id, vacancy_id)
);

-- Application 
CREATE TABLE IF NOT EXISTS application (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    person_id INT NOT NULL,
    vacancy_id INT NOT NULL,
    application_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    FOREIGN KEY (person_id) REFERENCES person(id),
    FOREIGN KEY (vacancy_id) REFERENCES vacancy(id)
);

-- Appliction Status 
CREATE TABLE IF NOT EXISTS application_status (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    application_id INT NOT NULL,
    status VARCHAR(100) NOT NULL DEFAULT 'New', -- New, Short listed, Accepted, Rejected, Pending, Called for interview, Interviewd, Offered, Offer accepted, offer rejected, Withdrawn, On hold
    updated TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, -- Latest application status would be SELECT * WHERE application_id = {target} ORDER BY timestamp DESC LIMIT 1;
    is_terminal BOOLEAN NOT NULL DEFAULT FALSE,
    FOREIGN KEY (application_id) REFERENCES application(id)
);

-- Evaluation 
CREATE TABLE IF NOT EXISTS evaluation (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    evaluatee_id INT NOT NULL,  -- select vacancy for application and then select evaluation criterial for vacancy, and for each of those criteria grade the applicant 
    evaluator_id INT DEFAULT NULL,
    evaluation_criteria_id INT NOT NULL,
    notes VARCHAR(1024) DEFAULT NULL,
    grade INT NOT NULL DEFAULT 0,
    updated TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (evaluatee_id) REFERENCES person(id),
    FOREIGN KEY (evaluator_id) REFERENCES person(id),
    FOREIGN KEY (evaluation_criteria_id) REFERENCES evaluation_criteria(id)
);

CREATE TABLE IF NOT EXISTS metadata (
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
