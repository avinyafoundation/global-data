USE avinya_db;

CREATE TABLE IF NOT EXISTS avinya_type (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    active BOOLEAN NOT NULL,
    global_type ENUM(
        "employee",
        "consultant",
        "customer",
        "volunteer",
        "applicant",
        "team",
        "advisor",
        "director",
        "donor"
    ) NOT NULL,
    name VARCHAR(255),
    foundation_type ENUM(
        "executive", -- Foundation Level
        "academic", -- specifically academic instruction
        "staff", -- l.t. (<) Foundation Level
        "parent",
        "student"
    ),
    focus ENUM(
        "bootcamp",
        "information-technology",
        "healthcare",
        "hospitality",
        "operations",
        "human-resources",
        "technology",
        "marketing",
        "finance"
    ),
    level INT
);
