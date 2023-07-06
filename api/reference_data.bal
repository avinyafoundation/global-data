public isolated service class ReferenceData {
    private Reference reference;

    isolated function init(int id, Reference? reference = null) returns error? {
        if(reference != null) { // if reference is provided, then use that and do not load from DB
            self.reference = reference.cloneReadOnly();
            return;
        }

          Reference  reference_raw = check db_client -> queryRow(
            `SELECT *
            FROM reference_number 
            WHERE id = ${id}`);
        
        self.reference = reference_raw.cloneReadOnly();
    }

    
    isolated resource function get id() returns int?|error {
        lock {
            return self.reference.id;
        }
    }

    isolated resource function get last_reference_no() returns int {
        lock {
            return self.reference.last_reference_no;
        }
    }

    isolated resource function get batch_no() returns int {
        lock {
            return self.reference.batch_no;
        }
    }

    isolated resource function get branch_code() returns string? {
        lock {
            return self.reference.branch_code;
        }
    }

    isolated resource function get foundation_type() returns string {
        lock {
            return self.reference.foundation_type;
        }
    }

    isolated resource function get acedemic_year() returns string {
        lock {
            return self.reference.acedemic_year;
        }
    }

}
