public isolated service class AlumniWorkExperienceData {

    private AlumniWorkExperience alumni_work_experience;

    isolated function init(int? id = 0, AlumniWorkExperience? alumni_work_experience = null) returns error? {

        if (alumni_work_experience != null) {
            self.alumni_work_experience = alumni_work_experience.cloneReadOnly();
            return;
        }

        lock {

            AlumniWorkExperience alumni_work_experience_raw;

            if (id > 0) {

                alumni_work_experience_raw = check db_client->queryRow(
                                    `SELECT *
                                    FROM alumni_work_experience
                                    WHERE id = ${id};`
                                );

            } else {
                return error("No id provided");
            }

            self.alumni_work_experience = alumni_work_experience_raw.cloneReadOnly();
        }
    }

    isolated resource function get id() returns int?|error {
        lock {
            return self.alumni_work_experience.id;
        }
    }

    isolated resource function get person_id() returns int?|error {
        lock {
            return self.alumni_work_experience.person_id;
        }
    }

    isolated resource function get company_name() returns string?|error {
        lock {
            return self.alumni_work_experience.company_name;
        }
    }

    isolated resource function get job_title() returns string?|error {
        lock {
            return self.alumni_work_experience.job_title;
        }
    }

    isolated resource function get currently_working() returns boolean?|error {
        lock {
            return self.alumni_work_experience.currently_working;
        }
    }

    isolated resource function get start_date() returns string?|error {
        lock {
            return self.alumni_work_experience.start_date;
        }
    }

    isolated resource function get end_date() returns string?|error {
        lock {
            return self.alumni_work_experience.end_date;
        }
    }

    isolated resource function get created() returns string?|error {
        lock {
            return self.alumni_work_experience.created;
        }
    }

    isolated resource function get updated() returns string?|error {
        lock {
            return self.alumni_work_experience.updated;
        }
    }
}
