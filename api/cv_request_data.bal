public isolated service class CvRequestData {

    private CvRequest cv_request;

    isolated function init(int? id = 0, int? personId = 0, CvRequest? cvRequest = null) returns error? {

        if (cvRequest != null) {
            self.cv_request = cvRequest.cloneReadOnly();
            return;
        }

        lock {
            CvRequest cv_request_raw;

            if (id > 0 && personId == 0) {

                cv_request_raw = check db_client->queryRow(
                `SELECT *
                FROM cv_request
                WHERE id = ${id};`);

            } else if(personId > 0 && id == 0) {

                cv_request_raw = check db_client->queryRow(
                `SELECT *
                FROM cv_request
                WHERE person_id = ${personId};`);

            }else{
               return error("Invalid request : either id or person Id must be greater than 0");
            }

            self.cv_request = cv_request_raw.cloneReadOnly();

        }
    }

    isolated resource function get id() returns int?|error {
        lock {
            return self.cv_request.id;
        }
    }

    isolated resource function get person_id() returns int?|error {
        lock {
            return self.cv_request.person_id;
        }
    }

    isolated resource function get phone() returns int?|error {
        lock {
            return self.cv_request.phone;
        }
    }

    isolated resource function get status() returns string?|error {
        lock {
            return self.cv_request.status;
        }
    }

    isolated resource function get created() returns string?|error {
        lock {
            return self.cv_request.created;
        }
    }

    isolated resource function get updated() returns string?|error {
        lock {
            return self.cv_request.updated;
        }
    }

}
