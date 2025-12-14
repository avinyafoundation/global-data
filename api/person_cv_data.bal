public isolated service class PersonCvData {

    private PersonCv person_cv;

    isolated function init(int? id = 0, int? personId = 0, PersonCv? personCv = null) returns error? {

        if (personCv != null) {
            self.person_cv = personCv.cloneReadOnly();
            return;
        }

        lock {
            PersonCv person_cv_raw;

            if (id > 0 && personId == 0) {

                person_cv_raw = check db_client->queryRow(
                `SELECT *
                FROM person_cv
                WHERE id = ${id};`);

            } else if (personId > 0 && id == 0) {

                person_cv_raw = check db_client->queryRow(
                `SELECT *
                FROM person_cv
                WHERE person_id = ${personId};`);

            } else {
                return error("Invalid request : either id or person Id must be greater than 0");
            }

            self.person_cv = person_cv_raw.cloneReadOnly();

        }
    }

    isolated resource function get id() returns int?|error {
        lock {
            return self.person_cv.id;
        }
    }

    isolated resource function get person_id() returns int?|error {
        lock {
            return self.person_cv.person_id;
        }
    }

    isolated resource function get drive_file_id() returns string?|error {
        lock {
            return self.person_cv.drive_file_id;
        }
    }

    //get person cv in base64 format
    isolated resource function get file_content() returns string?|error { 
        lock {
            return self.person_cv.file_content;
        }
    }

    isolated resource function get uploaded_by() returns string?|error {
        lock {
            return self.person_cv.uploaded_by;
        }
    }

    isolated resource function get created() returns string?|error {
        lock {
            return self.person_cv.created;
        }
    }

    isolated resource function get updated() returns string?|error {
        lock {
            return self.person_cv.updated;
        }
    }

}
