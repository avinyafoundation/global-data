public isolated service class PersonFcmTokenData {

    private PersonFcmToken person_fcm_token;

    isolated function init(int? id = 0, int? personId = 0, PersonFcmToken? personFcmToken = null) returns error? {

        if (personFcmToken != null) {
            self.person_fcm_token = personFcmToken.cloneReadOnly();
            return;
        }

        lock {
            PersonFcmToken person_fcm_token_raw;

            if (id > 0 && personId == 0) {

                person_fcm_token_raw = check db_client->queryRow(
                `SELECT *
                FROM person_fcm_token
                WHERE id = ${id};`);

            } else if (personId > 0 && id == 0) {

                person_fcm_token_raw = check db_client->queryRow(
                `SELECT *
                FROM person_fcm_token
                WHERE person_id = ${personId};`);

            } else {
                return error("Invalid request : either id or person Id must be greater than 0");
            }

            self.person_fcm_token = person_fcm_token_raw.cloneReadOnly();

        }
    }

    isolated resource function get id() returns int?|error {
        lock {
            return self.person_fcm_token.id;
        }
    }

    isolated resource function get person_id() returns int?|error {
        lock {
            return self.person_fcm_token.person_id;
        }
    }

    isolated resource function get fcm_token() returns string?|error {
        lock {
            return self.person_fcm_token.fcm_token;
        }
    }

    isolated resource function get created() returns string?|error {
        lock {
            return self.person_fcm_token.created;
        }
    }

    isolated resource function get updated() returns string?|error {
        lock {
            return self.person_fcm_token.updated;
        }
    }

}
