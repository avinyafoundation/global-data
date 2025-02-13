public isolated service class AlumniEducationQualificationsData {

    private AlumniEducationQualifications alumni_education_qualifications;

    isolated function init(int? id = 0, AlumniEducationQualifications? alumni_education_qualifications = null) returns error? {

        if (alumni_education_qualifications != null) {
            self.alumni_education_qualifications = alumni_education_qualifications.cloneReadOnly();
            return;
        }

        lock {

            AlumniEducationQualifications alumni_education_qualifications_raw;

            if (id > 0) {

                alumni_education_qualifications_raw = check db_client->queryRow(
                                    `SELECT *
                                    FROM alumni_education_qualifications
                                    WHERE id = ${id};`
                                );

            } else {
                return error("No id provided");
            }

            self.alumni_education_qualifications = alumni_education_qualifications_raw.cloneReadOnly();
        }
    }

    isolated resource function get id() returns int?|error {
        lock {
            return self.alumni_education_qualifications.id;
        }
    }

    isolated resource function get person_id() returns int?|error {
        lock {
            return self.alumni_education_qualifications.person_id;
        }
    }

    isolated resource function get university_name() returns string?|error {
        lock {
            return self.alumni_education_qualifications.university_name;
        }
    }

    isolated resource function get course_name() returns string?|error {
        lock {
            return self.alumni_education_qualifications.course_name;
        }
    }

    isolated resource function get is_currently_studying() returns boolean?|error {
        lock {
            return self.alumni_education_qualifications.is_currently_studying;
        }
    }

    isolated resource function get start_date() returns string?|error {
        lock {
            return self.alumni_education_qualifications.start_date;
        }
    }

    isolated resource function get end_date() returns string?|error {
        lock {
            return self.alumni_education_qualifications.end_date;
        }
    }

    isolated resource function get created() returns string?|error {
        lock {
            return self.alumni_education_qualifications.created;
        }
    }

    isolated resource function get updated() returns string?|error {
        lock {
            return self.alumni_education_qualifications.updated;
        }
    }
}
