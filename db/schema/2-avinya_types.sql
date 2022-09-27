USE avinya_db;

CREATE TABLE IF NOT EXISTS avinya_type (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    active BOOLEAN NOT NULL,
    global_type ENUM("Employee", "Customer", "Volunteer", "Applicant", "Team") NOT NULL,
    name VARCHAR(255),
    foundation_type ENUM(
        "Advisors",
        "Educator",
        "Technology",
        "Operations",
        "Parent",
        "Student"
    ),
    focus ENUM(
        "Bootcamp",
        "Healthcare",
        "Information Technology"
    ),
    level INT
);
