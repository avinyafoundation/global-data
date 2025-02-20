public isolated service class AlumniEducationQualificationData {

    private AlumniEducationQualification alumni_education_qualification;

    isolated function init(int? id = 0, AlumniEducationQualification? alumni_education_qualification = null) returns error? {

        if (alumni_education_qualification != null) {
            self.alumni_education_qualification = alumni_education_qualification.cloneReadOnly();
            return;
        }

        lock {

            AlumniEducationQualification alumni_education_qualification_raw;

            if (id > 0) {

                alumni_education_qualification_raw = check db_client->queryRow(
                                    `SELECT *
                                    FROM alumni_education_qualifications
                                    WHERE id = ${id};`
                                );

            } else {
                return error("No id provided");
            }

            self.alumni_education_qualification = alumni_education_qualification_raw.cloneReadOnly();
        }
    }

    isolated resource function get id() returns int?|error {
        lock {
            return self.alumni_education_qualification.id;
        }
    }

    isolated resource function get person_id() returns int?|error {
        lock {
            return self.alumni_education_qualification.person_id;
        }
    }

    isolated resource function get university_name() returns string?|error {
        lock {
            return self.alumni_education_qualification.university_name;
        }
    }

    isolated resource function get course_name() returns string?|error {
        lock {
            return self.alumni_education_qualification.course_name;
        }
    }

    isolated resource function get is_currently_studying() returns int?|error {
        lock {
            return self.alumni_education_qualification.is_currently_studying;
        }
    }

    isolated resource function get start_date() returns string?|error {
        lock {
            return self.alumni_education_qualification.start_date;
        }
    }

    isolated resource function get end_date() returns string?|error {
        lock {
            return self.alumni_education_qualification.end_date;
        }
    }

    isolated resource function get created() returns string?|error {
        lock {
            return self.alumni_education_qualification.created;
        }
    }

    isolated resource function get updated() returns string?|error {
        lock {
            return self.alumni_education_qualification.updated;
        }
    }
}
