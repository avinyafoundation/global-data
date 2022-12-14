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
    evaluation_type VARCHAR(100) DEFAULT 'Essay', -- Essay, Multiple Choice, True/False, Rating
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
    updated TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Latest application status would be SELECT * WHERE application_id = {target} ORDER BY timestamp DESC LIMIT 1;
    is_terminal BOOLEAN NOT NULL DEFAULT FALSE,
    FOREIGN KEY (application_id) REFERENCES application(id)
);


CREATE TABLE IF NOT EXISTS applicant_consent (
	id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    organization_id INT DEFAULT NULL,
    avinya_type_id INT DEFAULT NULL,
    person_id INT DEFAULT NULL,
    application_id INT DEFAULT NULL,
    name VARCHAR(100) NOT NULL DEFAULT 'Anon',
    date_of_birth DATE NOT NULL DEFAULT '1990-01-01',
    done_ol BOOL DEFAULT false,
    ol_year INT NOT NULL DEFAULT '2000',
    distance_to_school INT DEFAULT 500, 
    phone BIGINT NOT NULL DEFAULT 0,
    email VARCHAR(254) DEFAULT 'me@you.com',
    information_correct_consent BOOL DEFAULT FALSE,
    agree_terms_consent BOOL DEFAULT FALSE,
    created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (person_id) REFERENCES person(id),
    FOREIGN KEY (organization_id) REFERENCES organization(id),
    FOREIGN KEY (avinya_type_id) REFERENCES avinya_type(id),
    FOREIGN KEY (application_id) REFERENCES application(id)
);

CREATE TABLE IF NOT EXISTS prospect (
	id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    name VARCHAR(100) NOT NULL DEFAULT 'Anon',
    phone BIGINT NOT NULL DEFAULT 0,
    email VARCHAR(254) DEFAULT 'me@you.com',
    receive_information_consent BOOL DEFAULT FALSE,
    agree_terms_consent BOOL DEFAULT FALSE,
    created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    street_address VARCHAR(255) DEFAULT NULL,
    date_of_birth DATE DEFAULT NULL,
    done_ol BOOLEAN DEFAULT NULL,
    ol_year INT NULL DEFAULT NULL,
    distance_to_school INT DEFAULT NULL,
    verified BOOLEAN DEFAULT FALSE,
    contacted BOOLEAN DEFAULT FALSE,
    applied BOOLEAN DEFAULT FALSE
);

