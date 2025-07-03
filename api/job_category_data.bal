public isolated service class JobCategoryData {

    private JobCategory job_category;

    isolated function init(int? id = 0, JobCategory? job_category = null) returns error? {

        if (job_category != null) {
            self.job_category = job_category.cloneReadOnly();
            return;
        }

        lock {

            JobCategory job_category_raw;

            if (id > 0) {

                job_category_raw = check db_client->queryRow(
                                    `SELECT *
                                    FROM job_category
                                    WHERE id = ${id};`
                                );

            } else {
                return error("No id provided");
            }

            self.job_category = job_category_raw.cloneReadOnly();
        }
    }

    isolated resource function get id() returns int?|error {
        lock {
            return self.job_category.id;
        }
    }

    isolated resource function get name() returns string?|error {
        lock {
            return self.job_category.name;
        }
    }

    isolated resource function get description() returns string?|error {
        lock {
            return self.job_category.description;
        }
    }
}
