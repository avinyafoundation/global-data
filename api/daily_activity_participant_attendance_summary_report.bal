public isolated service class DailyActivityParticipantAttendanceSummaryReportData {
    private ActivityParticipantAttendanceSummaryReport activity_participant_attendance_summary_report = {
        sign_in_date: "",
        present_count: -1,
        late_count:-1,
        total_count:-1,
        present_attendance_percentage:0.0,
        late_attendance_percentage: 0.0 
    };

    isolated function init(ActivityParticipantAttendanceSummaryReport? activity_participant_attendance_summary_report = null) returns error? {
        if(activity_participant_attendance_summary_report != null) {
            self.activity_participant_attendance_summary_report = activity_participant_attendance_summary_report.cloneReadOnly();
            return;
        }
        
    }


    isolated resource function get sign_in_date() returns string? {
        lock {
                return self.activity_participant_attendance_summary_report.sign_in_date;
        }
    }

    isolated resource function get present_count() returns int? {
        lock {
                return self.activity_participant_attendance_summary_report.present_count;
        }
    }


    isolated resource function get late_count() returns int? {
        lock {
                return self.activity_participant_attendance_summary_report.late_count;
        }
    }

    isolated resource function get total_count() returns int? {
        lock {
                return self.activity_participant_attendance_summary_report.total_count;
        }
    }

    isolated resource function get present_attendance_percentage() returns decimal? {

      lock {
           return self.activity_participant_attendance_summary_report.present_attendance_percentage;
        }
    }

    isolated resource function get late_attendance_percentage() returns decimal? {
        lock {
           return self.activity_participant_attendance_summary_report.late_attendance_percentage;
        }
    }
}
