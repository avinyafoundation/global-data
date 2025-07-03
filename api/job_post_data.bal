public isolated service class JobPostData {

    private JobPost job_post;

    isolated function init(int? id = 0, JobPost? job_post = null) returns error? {

        if (job_post != null) {
            self.job_post = job_post.cloneReadOnly();
            return;
        }

        lock {

            JobPost job_post_raw;

            if (id > 0) {

                job_post_raw = check db_client->queryRow(
                                    `SELECT *
                                    FROM job_post
                                    WHERE id = ${id};`
                                );

            } else {
                return error("No id provided");
            }

            self.job_post = job_post_raw.cloneReadOnly();
        }
    }

    isolated resource function get id() returns int?|error {
        lock {
            return self.job_post.id;
        }
    }

    isolated resource function get job_type() returns string?|error {
        lock {
            return self.job_post.job_type;
        }
    }

    isolated resource function get job_text() returns string?|error {
        lock {
            return self.job_post.job_text;
        }
    }

    isolated resource function get job_link() returns string?|error {
        lock {
            return self.job_post.job_link;
        }
    }

    isolated resource function get job_image_drive_id() returns string?|error {
        lock {
            return self.job_post.job_image_drive_id;
        }
    }

    isolated resource function get job_category_id() returns int?|error {
        lock {
            return self.job_post.job_category_id;
        }
    }

    isolated resource function get application_deadline() returns string?|error {
        lock {
            return self.job_post.application_deadline;
        }
    }

    isolated resource function get uploaded_by() returns string?|error {
        lock {
            return self.job_post.uploaded_by;
        }
    }

    isolated resource function get job_post_image() returns string?|error {
        lock {
            return self.job_post.job_post_image;
        }
    }

    isolated resource function get created() returns string?|error {
        lock {
            return self.job_post.created;
        }
    }

    isolated resource function get updated() returns string?|error {
        lock {
            return self.job_post.updated;
        }
    }
}
