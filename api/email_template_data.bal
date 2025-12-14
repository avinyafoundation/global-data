public isolated service class EmailTemplateData {

    private EmailTemplate email_template;

    isolated function init(int? id = 0,EmailTemplate? emailTemplate = null) returns error? {

        if (emailTemplate != null) {
            self.email_template = emailTemplate.cloneReadOnly();
            return;
        }

        lock {
            EmailTemplate email_template_raw;

            if (id > 0) {

                email_template_raw = check db_client->queryRow(
                `SELECT *
                FROM email_template
                WHERE id = ${id};`);

            } else {
                return error("Invalid request : id must be greater than 0");
            }

            self.email_template = email_template_raw.cloneReadOnly();

        }
    }

    isolated resource function get id() returns int?|error {
        lock {
            return self.email_template.id;
        }
    }

    isolated resource function get template_key() returns string?|error {
        lock {
            return self.email_template.template_key;
        }
    }

    isolated resource function get subject() returns string?|error {
        lock {
            return self.email_template.subject;
        }
    }

    isolated resource function get template() returns string?|error {
        lock {
            return self.email_template.template;
        }
    }

    isolated resource function get created() returns string?|error {
        lock {
            return self.email_template.created;
        }
    }

    isolated resource function get updated() returns string?|error {
        lock {
            return self.email_template.updated;
        }
    }

}
