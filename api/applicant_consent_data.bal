public isolated service class ApplicantConsentData {
    private ApplicantConsent applicant_consent;

    isolated function init(string? name = null, int? applicant_consent_id = 0, ApplicantConsent? applicant_consent = null) returns error? {
        if(applicant_consent != null) { // if applicant_consent is provided, then use that and do not load from DB
            self.applicant_consent = applicant_consent.cloneReadOnly();
            return;
        }

        string _name = "%" + (name ?: "") + "%";
        int id = applicant_consent_id ?: 0;

        ApplicantConsent org_raw;
        if(id > 0) { // applicant_consent_id provided, give precedance to that
            org_raw = check db_client -> queryRow(
            `SELECT *
            FROM avinya_db.applicant_consent
            WHERE
                id = ${id};`);
        } else 
        {
            org_raw = check db_client -> queryRow(
            `SELECT *
            FROM avinya_db.applicant_consent
            WHERE
                name_en LIKE ${_name};`);
        }
        
        self.applicant_consent = org_raw.cloneReadOnly();
    }

    isolated resource function get avinya_type() returns AvinyaTypeData|error? {
        int id = 0;
        lock {
            id = self.applicant_consent.avinya_type_id ?: 0;
            if( id == 0) {
                return null; // no point in querying if address id is null
            } 
        }
        
        return new AvinyaTypeData(id);
    }

    isolated resource function get phone() returns int? {
        lock {
            return self.applicant_consent.phone;
        }
    }

    isolated resource function get name() returns string? {
        lock {
            return self.applicant_consent.name;
        }
    }

    
    isolated resource function get id() returns int? {
        lock {
            return self.applicant_consent.id;
        }
    }

    isolated resource function get email() returns string? {
        lock {
            return self.applicant_consent.email;
        }
    }

    isolated resource function get date_of_birth() returns string? {
        lock {
            return self.applicant_consent.date_of_birth;
        }
    }

    isolated resource function get done_ol() returns boolean? {
        lock {
            return self.applicant_consent.done_ol;
        }
    }

    isolated resource function get distance_to_school() returns int? {
        lock {
            return self.applicant_consent.distance_to_school;
        }
    }

    isolated resource function get information_correct_consent() returns boolean? {
        lock {
            return self.applicant_consent.information_correct_consent;
        }
    }

    isolated resource function get agree_terms_consent() returns boolean? {
        lock {
            return self.applicant_consent.agree_terms_consent;
        }
    }

}
