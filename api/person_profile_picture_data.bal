public isolated service class PersonProfilePictureData {
    private PersonProfilePicture person_profile_picture;

    isolated function init(int? id = 0,int? person_id = 0,PersonProfilePicture? person_profile_picture = null) returns error? {

        if (person_profile_picture != null) {
            self.person_profile_picture = person_profile_picture.cloneReadOnly();
            return;
        }
        lock {

            PersonProfilePicture person_profile_picture_raw;

            if (id > 0) {

                person_profile_picture_raw = check db_client->queryRow(
                `SELECT *
                FROM person_profile_pictures
                WHERE id = ${id};`);

            }else if(person_id > 0){
                person_profile_picture_raw = check db_client->queryRow(
                `SELECT *
                FROM person_profile_pictures
                WHERE person_id = ${person_id};`);
            }else {
                return error("No id provided");
            }
            self.person_profile_picture = person_profile_picture_raw.cloneReadOnly();
        }
    }

    isolated resource function get id() returns int?|error {
        lock {
            return self.person_profile_picture.id;
        }
    }

    isolated resource function get person_id() returns int?|error {
        lock {
            return self.person_profile_picture.person_id;
        }
    }

    isolated resource function get profile_picture_drive_id() returns string?|error {
        lock {
            return self.person_profile_picture.profile_picture_drive_id;
        }
    }

    isolated resource function get uploaded_by() returns string?|error {
        lock {
            return self.person_profile_picture.uploaded_by;
        }
    }

    isolated resource function get created() returns string?|error {
        lock {
            return self.person_profile_picture.created;
        }
    }

    isolated resource function get updated() returns string?|error {
        lock {
            return self.person_profile_picture.updated;
        }
    }

    isolated resource function get picture() returns string?|error {
        lock {
            return self.person_profile_picture.picture;
        }
    }
}

