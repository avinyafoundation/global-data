public isolated service class AlumniData {

    private Alumni alumni;

    isolated function init(int? id = 0, Alumni? alumni = null) returns error? {

        if (alumni != null) {
            self.alumni = alumni.cloneReadOnly();
            return;
        }

        lock {

            Alumni alumni_raw;

            if (id > 0) {

                alumni_raw = check db_client->queryRow(
                                    `SELECT *
                                    FROM alumni
                                    WHERE id = ${id};`
                                );

            } else {
                return error("No id provided");
            }

            self.alumni = alumni_raw.cloneReadOnly();
        }
    }

    isolated resource function get id() returns int?|error {
        lock {
            return self.alumni.id;
        }
    }

    isolated resource function get status() returns string?|error {
        lock {
            return self.alumni.status;
        }
    }

    isolated resource function get company_name() returns string?|error {
        lock {
            return self.alumni.company_name;
        }
    }

    isolated resource function get job_title() returns string?|error {
        lock {
            return self.alumni.job_title;
        }
    }

    isolated resource function get linkedin_id() returns string?|error {
        lock {
            return self.alumni.linkedin_id;
        }
    }

    isolated resource function get facebook_id() returns string?|error {
        lock {
            return self.alumni.facebook_id;
        }
    }

    isolated resource function get instagram_id() returns string?|error {
        lock {
            return self.alumni.instagram_id;
        }
    }

    isolated resource function get tiktok_id() returns string?|error {
        lock {
            return self.alumni.tiktok_id;
        }
    }

    isolated resource function get updated_by() returns string?|error {
        lock {
            return self.alumni.updated_by;
        }
    }

    isolated resource function get created() returns string?|error {
        lock {
            return self.alumni.created;
        }
    }

    isolated resource function get updated() returns string?|error {
        lock {
            return self.alumni.updated;
        }
    }

    isolated resource function get person_count() returns int?|error {
        lock {
            return self.alumni.person_count;
        }
    }
}
