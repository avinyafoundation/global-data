USE avinya_db;

CREATE TABLE IF NOT EXISTS avinya_type (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    active BOOLEAN NOT NULL,
    global_type ENUM("Employee", "Customer", "Volunteer", "Applicant", "Organization", "Team") NOT NULL,
    name VARCHAR(255),
    foundation_type ENUM(
        "Executive",
        "Advisor",
        "Educator",
        "Technology",
        "Operations",
        "HR",
        "Parent",
        "Student"
    ),
    focus ENUM(
        "Foundation",
        "Vocational-IT",
        "Vocational-Healthcare",
        "Vocational-Hospitality",
        "Operations",
        "HR",
        "Technology"
    ),
    level INT
);
