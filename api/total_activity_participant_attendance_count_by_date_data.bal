public isolated service class TotalActivityParticipantAttendanceCountByDateData {
    private TotalActivityParticipantAttendanceCountByDate total_activity_participant_attendance_count_by_date = {
        attendance_date: "",
        daily_total: -1
    };

    isolated function init(TotalActivityParticipantAttendanceCountByDate? total_activity_participant_attendance_count_by_date = null) returns error? {
        if(total_activity_participant_attendance_count_by_date != null) { // if activity_participant_attendance is provided, then use that and do not load from DB
            self.total_activity_participant_attendance_count_by_date = total_activity_participant_attendance_count_by_date.cloneReadOnly();
            return;
        }
        
    }

    isolated resource function get attendance_date() returns string? {
        lock {
                return self.total_activity_participant_attendance_count_by_date.attendance_date;
        }
    }

    isolated resource function get daily_total() returns int? {
        lock {
                return self.total_activity_participant_attendance_count_by_date.daily_total;
        }
    }
    
}
