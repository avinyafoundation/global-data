public isolated service class ProspectData {
    private Prospect prospect;

    isolated function init(string? email = null, int? phone = 0, Prospect? prospect = null) returns error? {
        if(prospect != null) { // if prospect is provided, then use that and do not load from DB
            self.prospect = prospect.cloneReadOnly();
            return;
        }

        // string _email = "%" + (email ?: "") + "%";
        int _phone = phone ?: 0;

        Prospect consent_raw;
        if(_phone > 0) { // phone provided, give precedance to that
            consent_raw = check db_client -> queryRow(
            `SELECT *
            FROM avinya_db.prospect
            WHERE
                phone = ${_phone};`);
        } else if (email != null) { // if phone is not provided, then use email
            consent_raw = check db_client -> queryRow(
            `SELECT *
            FROM avinya_db.prospect
            WHERE
                email = ${email};`);
        } else {
            return error("No email or phone provided");
        }
        
        self.prospect = consent_raw.cloneReadOnly();
    }

    isolated resource function get active() returns boolean? {
        lock {
            return self.prospect.active;
        }
    }

    isolated resource function get phone() returns int? {
        lock {
            return self.prospect.phone;
        }
    }

    isolated resource function get name() returns string? {
        lock {
            return self.prospect.name;
        }
    }
    
    isolated resource function get id() returns int? {
        lock {
            return self.prospect.id;
        }
    }

    isolated resource function get email() returns string? {
        lock {
            return self.prospect.email;
        }
    }


    isolated resource function get receive_information_consent() returns boolean? {
        lock {
            return self.prospect.receive_information_consent;
        }
    }

    isolated resource function get agree_terms_consent() returns boolean? {
        lock {
            return self.prospect.agree_terms_consent;
        }
    }

    isolated resource function get created() returns string? {
        lock {
            return self.prospect.created;
        }
    }

}
