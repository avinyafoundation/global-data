public isolated service class ActivityInstanceData {
    private ActivityInstance activity_instance;
    private int? person_id=-1;

    isolated function init(string? name = null, int? activity_id = 0, ActivityInstance? activity_instance = null,int? person_id = 0) returns error? {
        if(activity_instance != null) { // if activity_instance is provided, then use that and do not load from DB
            self.person_id = person_id;
            self.activity_instance = activity_instance.cloneReadOnly();
            return;
        }
        
        string _name = "%" + (name ?: "") + "%";
        int id = activity_id ?: 0;

        ActivityInstance activity_instance_raw;
        if(id > 0) { // activity_instance_id provided, give precedance to that
            activity_instance_raw = check db_client -> queryRow(
            `SELECT *
            FROM activity_instance
            WHERE
                id = ${id};`);
        } else 
        {
            activity_instance_raw = check db_client -> queryRow(
            `SELECT *
            FROM activity_instance
            WHERE
                name_en LIKE ${_name};`);
        }
        self.activity_instance = activity_instance_raw.cloneReadOnly();
    }

    private isolated function calculate_overdue_days() returns int|error? {
        int? activityInstanceId;
        lock {
            activityInstanceId = self.activity_instance.id;
        }
        
        if activityInstanceId is int {
            record {|decimal overdue_days;|}|error overdueDaysRecord = db_client->queryRow(
                `SELECT 
                    CASE 
                        WHEN overall_task_status = 'Completed' THEN 0
                        WHEN end_time IS NULL THEN 0
                        WHEN end_time < NOW() THEN FLOOR(TIMESTAMPDIFF(SECOND, end_time, NOW()) / 86400)
                        WHEN end_time >= NOW() THEN -FLOOR(TIMESTAMPDIFF(SECOND, NOW(), end_time) / 86400)
                        ELSE 0
                    END AS overdue_days
                FROM activity_instance
                WHERE id = ${activityInstanceId}`
            );
            
            if overdueDaysRecord is record {|decimal overdue_days;|} {
                return <int>overdueDaysRecord.overdue_days;
            }
            
            return 0;
        }
        
        return 0;
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

    isolated resource function get location() returns string? {
        lock {
            return self.activity_instance.location;
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

    isolated resource function get task_id() returns int? {
        lock {
            return self.activity_instance.task_id;
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

    //get task details
    isolated resource function get task() returns MaintenanceTaskData|error? {
        int id = 0;
        lock {
            id = self.activity_instance.task_id ?: 0;
            if( id == 0) {
                return null;
            } 
        }
        
        return new MaintenanceTaskData(id);
    }

    isolated resource function get finance() returns MaintenanceFinanceData|error? {
        int id = 0;
        lock {
            id = self.activity_instance.id ?: 0;
            if( id == 0) {
                return null;
            } 
        }

        MaintenanceFinance|error? financeCheck;
        lock {
            financeCheck = db_client->queryRow(
                `SELECT * FROM maintenance_finance WHERE activity_instance_id = ${id}`
            );
        }
        
        // Return null if no finance record exists instead of throwing error
        if financeCheck is error {
            return null;
        }
        
        return new MaintenanceFinanceData(0, id);
    }

    isolated resource function get overall_task_status() returns string? {
        lock {
            return self.activity_instance.overall_task_status;
        }
    }

    isolated resource function get overdue_days() returns int|error? {
        return self.calculate_overdue_days();
    }

    isolated resource function get statusText() returns string|error? {
        int overdueDays = check self.calculate_overdue_days() ?: 0;
        
        if overdueDays > 0 {
            // Task is overdue
            string dayText = overdueDays == 1 ? "day" : "days";
            return string `Overdue by ${overdueDays} ${dayText}`;
        } else if overdueDays < 0 {
            // Task is due soon (within next 2 days)
            int daysUntilDue = -overdueDays;
            if daysUntilDue == 0 {
                return "Overdue today";
            } else if daysUntilDue <= 2 {
                string dayText = daysUntilDue == 1 ? "day" : "days";
                return string `Overdue in ${daysUntilDue} ${dayText}`;
            }
        }
        
        return "On Schedule";
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

    isolated resource function get organization() returns OrganizationData|error? {
        int id = 0;
        lock {
            id = self.activity_instance.organization_id ?: 0;
            if( id == 0) {
                return null; // no point in querying if address id is null
            } 
        }
        
        return new OrganizationData((), id);
    }

    isolated resource function get activity_participants() returns ActivityParticipantData[]|error? {
        stream<ActivityParticipant, error?> activityParticipants;
        lock {
            activityParticipants = db_client->query(
                `SELECT *
                FROM activity_participant
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
    
    isolated resource function get activity_participant() returns ActivityParticipantData|error? {
        ActivityParticipant|error? activity_participant_raw;
     
      lock{
        activity_participant_raw = db_client->queryRow(
            `SELECT *
            FROM activity_participant
            WHERE activity_instance_id = ${self.activity_instance.id} and person_id = ${self.person_id};`);
       }

            if (activity_participant_raw is ActivityParticipant) {
                return new (0,activity_participant_raw);
            } else {
            // Return a new empty Activity Participant object if no record is found
               ActivityParticipant activity_participant_empty_data = {
                    activity_instance_id: -1,
                    person_id: -1,
                    organization_id: -1,
                    start_date: "",
                    end_date: "",
                    participant_task_status: "",
                    role: "",
                    notes: "",
                    is_attending: -1,
                    created: "",
                    updated: ""
                };
                return new (0, activity_participant_empty_data);
            }
    }

    isolated resource function get activity_participant_attendances() returns ActivityParticipantAttendanceData[]|error? {
        stream<ActivityParticipantAttendance, error?> activityParticipantAttendances;
        lock {
            activityParticipantAttendances = db_client->query(
                `SELECT *
                FROM activity_participant_attendance
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
                FROM evaluation
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
    isolated resource function get event_gift() returns EventGiftData|error? {
        
        EventGift|error? event_gift_raw;

        lock {
            event_gift_raw = db_client->queryRow(
            `SELECT *
            FROM event_gift
            WHERE activity_instance_id = ${self.activity_instance.id};`);
        }

        if (event_gift_raw is EventGift) {

            return new (0,0,event_gift_raw);

        } else {

            // Return a new empty event gift object if no record is found
            EventGift event_gift_empty_data = {
                activity_instance_id: -1,
                gift_amount: 0.0,
                no_of_gifts: -1,
                notes: "",
                description: ""
            };
            return new (0,0,event_gift_empty_data);
        }
    }

    isolated resource function get activity_evaluation() returns ActivityInstanceEvaluationData|error? {
        ActivityInstanceEvaluation|error? activity_instance_evaluation_raw;
     
      lock{
            activity_instance_evaluation_raw = db_client->queryRow(
            `SELECT *
            FROM activity_instance_evaluation
            WHERE activity_instance_id = ${self.activity_instance.id} and evaluator_id = ${self.person_id};`);
       }

            if (activity_instance_evaluation_raw is ActivityInstanceEvaluation) {
            
                return new (0,activity_instance_evaluation_raw);
            
            } else {

            // Return a new empty Activity Evaluation object if no record is found
            ActivityInstanceEvaluation activity_evaluation_empty_data = {
                    activity_instance_id: -1,
                    evaluator_id: -1,
                    feedback: "",
                    rating: -1,
                    created: "",
                    updated: ""
                };
                return new (0, activity_evaluation_empty_data);
            }
    }
    
}
