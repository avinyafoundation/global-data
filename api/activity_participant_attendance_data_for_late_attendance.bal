public isolated service class ActivityParticipantAttendanceDataForLateAttendance {
    private ActivityParticipantAttendanceForLateAttendance activity_participant_attendance = {
        activity_instance_id: -1,
        person_id: -1,
        sign_in_time: "" ,
        sign_out_time: "" ,
        in_marked_by: "system@avinya.edu.lk",
        out_marked_by: "'system@avinya.edu.lk'",
        created: "",
        updated: "",
        description: "",
        preferred_name: "",
        digital_id: "",
        label: "",
        studentNames: "",
        studentCount: -1
     };

    isolated function init(int? activity_participant_attendance_id = 0, ActivityParticipantAttendanceForLateAttendance? activity_participant_attendance = null) returns error? {
        if(activity_participant_attendance != null) { // if activity_participant_attendance is provided, then use that and do not load from DB
            self.activity_participant_attendance = activity_participant_attendance.cloneReadOnly();
            return;
        }

        int _activity_participant_id = activity_participant_attendance_id ?: 0;

        ActivityParticipantAttendanceForLateAttendance activity_participant_raw;
        if(_activity_participant_id > 0) { // activity_participant_attendance_id provided, give precedance to that
            activity_participant_raw = check db_client -> queryRow(
            `SELECT *
            FROM activity_participant_attendance
            WHERE
                id = ${_activity_participant_id};`);
            self.activity_participant_attendance = activity_participant_raw.cloneReadOnly();
        } 
        
    }

    isolated resource function get id() returns int? {
        lock {
                return self.activity_participant_attendance.id;
        }
    }

    isolated resource function get activity_instance_id() returns int? {
        lock {
                return self.activity_participant_attendance.activity_instance_id;
        }
    }

    isolated resource function get person_id() returns int? {
        lock {
                return self.activity_participant_attendance.person_id;
        }
    }

    
    isolated resource function get person() returns PersonData|error? {
        int id = 0;
        lock {
            id = self.activity_participant_attendance.person_id ?: 0;
            if( id == 0) {
                return null; // no point in querying if person id is null
            } 
        }
        
        return new PersonData((), id);
    }


    isolated resource function get sign_in_time() returns string? {
        lock {
                return self.activity_participant_attendance.sign_in_time;
        }
    }

    isolated resource function get description() returns string? {
        lock {
                return self.activity_participant_attendance.description;
        }
    }

     isolated resource function get preferred_name() returns string? {
        lock {
                return self.activity_participant_attendance.preferred_name;
        }
    }

     isolated resource function get digital_id() returns string? {
        lock {
                return self.activity_participant_attendance.digital_id;
        }
    }

    isolated resource function get sign_out_time() returns string? {
        lock {
                return self.activity_participant_attendance.sign_out_time;
        }
    }

    isolated resource function get label() returns string? {
        lock {
            return self.activity_participant_attendance.label;
        }
    }

    isolated resource function get student_count() returns int? {
        lock {
            return self.activity_participant_attendance.studentCount;
        }
    }

    isolated resource function get student_name() returns string? {
        lock {
            return self.activity_participant_attendance.studentNames;
        }
    }

    isolated resource function get created() returns string? {
        lock {
                return self.activity_participant_attendance.created;
        }
    }

    isolated resource function get updated() returns string? {
        lock {
                return self.activity_participant_attendance.updated;
        }
    }

    isolated resource function get in_marked_by() returns string? {
        lock {
                return self.activity_participant_attendance.in_marked_by;
        }
    }

    isolated resource function get out_marked_by() returns string? {
        lock {
                return self.activity_participant_attendance.out_marked_by;
        }
    }
    
}
