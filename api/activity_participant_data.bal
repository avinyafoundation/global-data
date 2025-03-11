public isolated service class ActivityParticipantData {
    private ActivityParticipant activity_participant = {
        activity_instance_id: -1,
        person_id: -1,
        organization_id: -1,
        start_date: "" ,
        end_date: "" ,
        role: "" ,
        notes: "" ,
        is_attending:-1,
        created: "",
        updated: ""
     };

    isolated function init(int? activity_participant_id = 0, ActivityParticipant? activity_participant = null) returns error? {
        if(activity_participant != null) { // if activity_participant is provided, then use that and do not load from DB
            self.activity_participant = activity_participant.cloneReadOnly();
            return;
        }

        int _activity_participant_id = activity_participant_id ?: 0;

        ActivityParticipant activity_instance_raw;
        if(_activity_participant_id > 0) { // activity_participant_id provided, give precedance to that
            activity_instance_raw = check db_client -> queryRow(
            `SELECT *
            FROM activity_participant
            WHERE
                id = ${_activity_participant_id};`);
            self.activity_participant = activity_instance_raw.cloneReadOnly();
        } 
        
    }

    isolated resource function get id() returns int?|error {
        lock {
                return self.activity_participant.id;
        }
    }

    isolated resource function get activity_instance_id() returns int?|error {
        lock {
                return self.activity_participant.activity_instance_id;
        }
    }

    isolated resource function get person_id() returns int?|error {
        lock {
            return self.activity_participant.person_id;
        }
    }

    isolated resource function get organization_id() returns int?|error {
        lock {
            return self.activity_participant.organization_id;
        }
    }

    
    isolated resource function get person() returns PersonData|error? {
        int id = 0;
        lock {
            id = self.activity_participant.person_id ?: 0;
            if( id == 0) {
                return null; // no point in querying if person id is null
            } 
        }
        
        return new PersonData((), id);
    }

    isolated resource function get organization() returns OrganizationData|error? {
        int id = 0;
        lock {
            id = self.activity_participant.organization_id ?: 0;
            if( id == 0) {
                return null; // no point in querying if person id is null
            } 
        }
        
        return new OrganizationData((), id);
    }

    isolated resource function get start_date() returns string?|error {
        lock {
                return self.activity_participant.start_date;
        }
    }

    isolated resource function get end_date() returns string?|error {
        lock {
                return self.activity_participant.end_date;
        }
    }

    isolated resource function get role() returns string?|error {
        lock {
                return self.activity_participant.role;
        }
    }

    isolated resource function get notes() returns string?|error {
        lock {
                return self.activity_participant.notes;
        }
    }

    isolated resource function get is_attending() returns int?|error {
        lock {
            return self.activity_participant.is_attending;
        }
    }

    isolated resource function get created() returns string?|error {
        lock {
                return self.activity_participant.created;
        }
    }

    isolated resource function get updated() returns string?|error {
        lock {
                return self.activity_participant.updated;
        }
    }
    
}
