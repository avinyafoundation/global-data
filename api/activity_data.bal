public isolated service class ActivityData {
    private Activity activity;

    isolated function init(string? name = null, int? activity_id = 0, Activity? activity = null) returns error? {
        if(activity != null) { // if activity is provided, then use that and do not load from DB
            self.activity = activity.cloneReadOnly();
            return;
        }

        string _name = "%" + (name ?: "") + "%";
        int id = activity_id ?: 0;

        Activity activity_raw;
        if(id > 0) { // activity_id provided, give precedance to that
            activity_raw = check db_client -> queryRow(
            `SELECT *
            FROM avinya_db.activity
            WHERE
                id = ${id};`);
        } else 
        {
            activity_raw = check db_client -> queryRow(
            `SELECT *
            FROM avinya_db.activity
            WHERE
                name LIKE ${_name};`);
        }
        
        self.activity = activity_raw.cloneReadOnly();
    }

    isolated resource function get id() returns int? {
        lock {
                return self.activity.id;
        }
    }

    isolated resource function get name() returns string? {
        lock {
                return self.activity.name;
        }
    }

    isolated resource function get description() returns string? {
        lock {
                return self.activity.description;
        }
    }

    isolated resource function get avinya_type() returns AvinyaTypeData|error? {
        int id = 0;
        lock {
            id = self.activity.avinya_type_id ?: 0;
            if( id == 0) {
                return null; // no point in querying if address id is null
            } 
        }
        
        return new AvinyaTypeData(id);
    }

    isolated resource function get notes() returns string? {
        lock {
            return self.activity.notes;
        }
    }

    isolated resource function get child_activities() returns ActivityData[]|error? {
        // Get list of child activitys
        stream<ParentChildActivity, error?> child_activity_ids;
        lock {
            child_activity_ids = db_client->query(
                `SELECT *
                FROM avinya_db.parent_child_activity
                WHERE parent_activity_id = ${self.activity.id}`
            );
        }

        ActivityData[] child_orgs = [];

        check from ParentChildActivity pco in child_activity_ids
            do {
                ActivityData|error candidate_org = new ActivityData((), pco.child_activity_id);
                if !(candidate_org is error) {
                    child_orgs.push(candidate_org);
                }
            };
        check child_activity_ids.close();
        return child_orgs;
    }

    isolated resource function get parent_activities() returns ActivityData[]|error? {
        // Get list of child activitys
        stream<ParentChildActivity, error?> parent_activity_ids;
        lock {
            parent_activity_ids = db_client->query(
                `SELECT *
                FROM avinya_db.parent_child_activity
                WHERE child_activity_id = ${self.activity.id}`
            );
        }

        ActivityData[] parent_orgs = [];

        check from ParentChildActivity pco in parent_activity_ids
            do {
                ActivityData|error candidate_org = new ActivityData((), pco.parent_activity_id);
                if !(candidate_org is error) {
                    parent_orgs.push(candidate_org);
                }
            };
        check parent_activity_ids.close();
        return parent_orgs;
    }

    isolated resource function get activity_sequence_plan() returns ActivitySequencePlanData[]|error? {
        stream<ActivitySequencePlan, error?> activity_sequence_plans;
        lock {
            activity_sequence_plans = db_client->query(
                `SELECT *
                FROM avinya_db.activity_sequence_plans
                WHERE activity_id = ${self.activity.id}`
            );
        }

        ActivitySequencePlanData[] activitySequencePlanDatas = [];

        check from ActivitySequencePlan activitySequencePlan in activity_sequence_plans
            do {
                ActivitySequencePlanData|error activitySequencePlanData = new ActivitySequencePlanData(0, activitySequencePlan);
                if !(activitySequencePlanData is error) {
                    activitySequencePlanDatas.push(activitySequencePlanData);
                }
            };

        check activity_sequence_plans.close();
        return activitySequencePlanDatas;
    }

    isolated resource function get activity_instances() returns ActivityInstanceData[]|error? {
        stream<ActivityInstance, error?> activity_instances;
        lock {
            activity_instances = db_client->query(
                `SELECT *
                FROM avinya_db.activity_instance
                WHERE activity_id = ${self.activity.id}`
            );
        }

        ActivityInstanceData[] activityInstanceDatas = [];

        check from ActivityInstance activityInstance in activity_instances
            do {
                ActivityInstanceData|error activityInstanceData = new ActivityInstanceData((), 0, activityInstance);
                if !(activityInstanceData is error) {
                    activityInstanceDatas.push(activityInstanceData);
                }
            };

        check activity_instances.close();
        return activityInstanceDatas;
    }
    
}
