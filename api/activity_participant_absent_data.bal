public isolated service class ActivityParticipantAbsentData {
    private ActivityParticipantAbsenceRaw activity_participant_absent = {
        absentCount: -1,
        absentNames: ""
    };

    isolated function init(ActivityParticipantAbsenceRaw? activity_participant_absent=null) returns error? {
        if (activity_participant_absent != null) { 
            self.activity_participant_absent = activity_participant_absent.cloneReadOnly();
            return;
        }
    }

    isolated resource function get absent_count() returns int? {
        lock {
            return self.activity_participant_absent.absentCount;
        }
    }

    isolated resource function get absent_names() returns string? {
        lock {
            return self.activity_participant_absent.absentNames;
        }
    }
}
