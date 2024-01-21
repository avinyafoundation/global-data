public isolated service class ActivityParticipantAttendanceMissedBySecurityData {
    private ActivityParticipantAttendanceMissedBySecurity activity_participant_attendance_missed_by_security = {
        sign_in_time: "",
        description: "",
        preferred_name:"",
        digital_id: ""
    };

    isolated function init(ActivityParticipantAttendanceMissedBySecurity? activity_participant_attendance_missed_by_security = null) returns error? {
        if(activity_participant_attendance_missed_by_security != null) { // if activity_participant_attendance is provided, then use that and do not load from DB
            self.activity_participant_attendance_missed_by_security = activity_participant_attendance_missed_by_security.cloneReadOnly();
            return;
        }
        
    }


    isolated resource function get sign_in_time() returns string? {
        lock {
                return self.activity_participant_attendance_missed_by_security.sign_in_time;
        }
    }

    isolated resource function get description() returns string? {
        lock {
                return self.activity_participant_attendance_missed_by_security.description;
        }
    }


    isolated resource function get preferred_name() returns string? {
        lock {
                return self.activity_participant_attendance_missed_by_security.preferred_name;
        }
    }

    isolated resource function get digital_id() returns string? {
        lock {
                return self.activity_participant_attendance_missed_by_security.digital_id;
        }
    }


    
}
