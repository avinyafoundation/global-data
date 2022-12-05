public isolated service class ActivityInstanceData {
    private ActivityInstance activity_instance;

    isolated function init(string? name = null, int? activity_id = 0, ActivityInstance? activity_instance = null) returns error? {
        if(activity_instance != null) { // if activity_instance is provided, then use that and do not load from DB
            self.activity_instance = activity_instance.cloneReadOnly();
            return;
        }

        string _name = "%" + (name ?: "") + "%";
        int id = activity_id ?: 0;

        ActivityInstance activity_instance_raw;
        if(id > 0) { // activity_instance_id provided, give precedance to that
            activity_instance_raw = check db_client -> queryRow(
            `SELECT *
            FROM avinya_db.activity_instance
            WHERE
                activity_id = ${id};`);
        } else 
        {
            activity_instance_raw = check db_client -> queryRow(
            `SELECT *
            FROM avinya_db.activity_instance
            WHERE
                name_en LIKE ${_name};`);
        }
        
        self.activity_instance = activity_instance_raw.cloneReadOnly();
    }

    isolated resource function get id() returns int? {
        lock {
                return self.activity_instance.id;
        }
    }

    isolated resource function get name() returns string? {
        lock {
                return self.activity_instance.name;
        }
    }

    isolated resource function get description() returns string? {
        lock {
                return self.activity_instance.description;
        }
    }

    isolated resource function get activity_id() returns int? {
        lock {
                return self.activity_instance.activity_id;
        }
    }

    isolated resource function get notes() returns string? {
        lock {
            return self.activity_instance.notes;
        }
    }

    isolated resource function get daily_sequence() returns int? {
        lock {
            return self.activity_instance.daily_sequence;
        }
    }

    isolated resource function get weekly_sequence() returns int? {
        lock {
            return self.activity_instance.weekly_sequence;
        }
    }

    isolated resource function get monthly_sequence() returns int? {
        lock {
            return self.activity_instance.monthly_sequence;
        }
    }

    isolated resource function get start_time() returns string? {
        lock {
            return self.activity_instance.start_time;
        }
    }

    isolated resource function get end_time() returns string? {
        lock {
            return self.activity_instance.end_time;
        }
    }

    isolated resource function get created() returns string? {
        lock {
            return self.activity_instance.created;
        }
    }

    isolated resource function get updated() returns string? {
        lock {
            return self.activity_instance.updated;
        }
    }

    isolated resource function get place() returns PlaceData|error? {
        int id = 0;
        lock {
            id = self.activity_instance.place_id ?: 0;
            if( id == 0) {
                return null; // no point in querying if address id is null
            } 
        }
        
        return new PlaceData((), id);
    }

    isolated resource function get activity_participants() returns ActivityParticipantData[]|error? {
        stream<ActivityParticipant, error?> activityParticipants;
        lock {
            activityParticipants = db_client->query(
                `SELECT *
                FROM avinya_db.activity_participant
                WHERE activity_instance_id = ${self.activity_instance.id}`
            );
        }

        ActivityParticipantData[] activityParticipantDatas = [];

        check from ActivityParticipant activityParticipant in activityParticipants
            do {
                ActivityParticipantData|error activityParticipantData = new ActivityParticipantData(0, activityParticipant);
                if !(activityParticipantData is error) {
                    activityParticipantDatas.push(activityParticipantData);
                }
            };

        check activityParticipants.close();
        return activityParticipantDatas;
    }

    isolated resource function get activity_participant_attendances() returns ActivityParticipantAttendanceData[]|error? {
        stream<ActivityParticipantAttendance, error?> activityParticipantAttendances;
        lock {
            activityParticipantAttendances = db_client->query(
                `SELECT *
                FROM avinya_db.activity_participant_attendance
                WHERE activity_instance_id = ${self.activity_instance.id}`
            );
        }

        ActivityParticipantAttendanceData[] activityParticipantAttendanceDatas = [];

        check from ActivityParticipantAttendance activityParticipantAttendance in activityParticipantAttendances
            do {
                ActivityParticipantAttendanceData|error activityParticipantAttendanceData = new ActivityParticipantAttendanceData(0, activityParticipantAttendance);
                if !(activityParticipantAttendanceData is error) {
                    activityParticipantAttendanceDatas.push(activityParticipantAttendanceData);
                }
            };

        check activityParticipantAttendances.close();
        return activityParticipantAttendanceDatas;
    }

    isolated resource function get evaluations() returns EvaluationData[]|error? {
        stream<Evaluation, error?> evaluations;
        lock {
            evaluations = db_client->query(
                `SELECT *
                FROM avinya_db.evaluation
                WHERE activity_instance_id = ${self.activity_instance.id}`
            );
        }

        EvaluationData[] evaluationDatas = [];

        check from Evaluation evaluation in evaluations
            do {
                EvaluationData|error evaluationData = new EvaluationData(0, evaluation);
                if !(evaluationData is error) {
                    evaluationDatas.push(evaluationData);
                }
            };

        check evaluations.close();
        return evaluationDatas;
    }
    
}
