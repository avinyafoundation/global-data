public isolated service class CalendarMetaData {

    private CalendarMetadata calendar_metadata;

    isolated function init(int? id=0, CalendarMetadata? calendarMetadata = null) returns error? {

        if (calendarMetadata != null) {
            self.calendar_metadata = calendarMetadata.cloneReadOnly();
            return;
        }

        lock {

            CalendarMetadata calendar_metadata_raw;

            if (id>0) {

                calendar_metadata_raw = check db_client->queryRow(
                `SELECT *
                FROM calendar_metadata
                WHERE id = ${id};`);

            } else {
                return error("No id provided");
            }

            self.calendar_metadata = calendar_metadata_raw.cloneReadOnly();

        }

    }

    isolated resource function get id() returns int?|error {
        lock {
            return self.calendar_metadata.id;
        }
    }

    isolated resource function get organization_id() returns int?|error {
        lock {
            return self.calendar_metadata.organization_id;
        }
    }

    isolated resource function get batch_id() returns int?|error {
        lock {
            return self.calendar_metadata.batch_id;
        }
    }


    isolated resource function get monthly_payment_amount() returns decimal?|error {
        lock {
            return self.calendar_metadata.monthly_payment_amount;
        }
    }

}
