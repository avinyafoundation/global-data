
public distinct service class AvinyaTypeData {
    private AvinyaType avinya_type;

    function init(int id) returns error? {
        AvinyaType avinya_type_raw = check db_client -> queryRow(
            `SELECT *
            FROM avinya_db.avinya_type
            WHERE id = ${id};`
        );

        self.avinya_type = avinya_type_raw.cloneReadOnly();
    }

    resource function get active() returns boolean|error {
        return self.avinya_type.active;
    }

    resource function get global_type() returns string? {
        return self.avinya_type.global_type;
    }

    resource function get name() returns string? {
        return self.avinya_type.name;
    }

    resource function get foundation_type() returns string? {
        return self.avinya_type.foundation_type;
    }

    resource function get focus() returns string? {
        return self.avinya_type.focus;
    }

    resource function get level() returns int? {
        return self.avinya_type.level;
    }
}
