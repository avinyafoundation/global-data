public isolated service class DailyActivityParticipantAttendanceByParentOrgData {
    private DailyActivityParticipantAttendanceByParentOrg daily_activity_participant_attendance_by_parent_org = {
        description: "",
        present_count: -1,
        svg_src : "",
        color : "",
        total_student_count : -1
    };

    isolated function init(DailyActivityParticipantAttendanceByParentOrg? daily_activity_participant_attendance_by_parent_org = null) returns error? {
        if(daily_activity_participant_attendance_by_parent_org != null) { // if activity_participant_attendance is provided, then use that and do not load from DB
            self.daily_activity_participant_attendance_by_parent_org = daily_activity_participant_attendance_by_parent_org.cloneReadOnly();
            return;
        }
        
    }


    isolated resource function get description() returns string? {
        lock {
                return self.daily_activity_participant_attendance_by_parent_org.description;
        }
    }

    isolated resource function get present_count() returns int? {
        lock {
                return self.daily_activity_participant_attendance_by_parent_org.present_count;
        }
    }

    isolated resource function get total_student_count() returns int? {
        lock {
                return self.daily_activity_participant_attendance_by_parent_org.total_student_count;
        }
    }


    isolated resource function get svg_src() returns string? {
        lock {
                return self.daily_activity_participant_attendance_by_parent_org.svg_src;
        }
    }

    isolated resource function get color() returns string? {
        lock {
                return self.daily_activity_participant_attendance_by_parent_org.color;
        }
    }

    
}
