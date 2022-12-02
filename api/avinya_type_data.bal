
public isolated service class AvinyaTypeData {
    private AvinyaType avinya_type;

    isolated function init(int id) returns error? {
        AvinyaType avinya_type_raw = check db_client -> queryRow(
            `SELECT *
            FROM avinya_db.avinya_type
            WHERE id = ${id};`
        );

        self.avinya_type = avinya_type_raw.cloneReadOnly();
    }

    isolated resource function get active() returns boolean|error {
        lock {
            return self.avinya_type.active;
        }
    }

    isolated resource function get global_type() returns string {
        lock {
            return self.avinya_type.global_type;
        }
    }

    isolated resource function get name() returns string? {
        lock {
            return self.avinya_type.name;
        }
    }

    isolated resource function get foundation_type() returns string? {
        lock {
            return self.avinya_type.foundation_type;
        }
    }

    isolated resource function get focus() returns string? {
        lock {
            return self.avinya_type.focus;
        }
    }

    isolated resource function get level() returns int? {
        lock {
            return self.avinya_type.level;
        }
    }
}
