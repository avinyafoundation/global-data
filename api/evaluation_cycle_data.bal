public isolated service class EvaluationCycleData {
    private EvaluationCycle evaluation_cycle;

    isolated function init(string? name = null, int? evaluation_cycle_id = 0, EvaluationCycle? evaluation_cycle = null) returns error? {
        if(evaluation_cycle != null) { // if evaluation_cycle is provided, then use that and do not load from DB
            self.evaluation_cycle = evaluation_cycle.cloneReadOnly();
            return;
        }

        string _name = "%" + (name ?: "") + "%";
        int id = evaluation_cycle_id ?: 0;

        EvaluationCycle evaluation_cycle_raw;
        if(id > 0) { // evaluation_cycle_id provided, give precedance to that
            evaluation_cycle_raw = check db_client -> queryRow(
            `SELECT *
            FROM evaluation_cycle
            WHERE
                id = ${id};`);
        } else 
        {
            evaluation_cycle_raw = check db_client -> queryRow(
            `SELECT *
            FROM evaluation_cycle
            WHERE
                name LIKE ${_name};`);
        }
        
        self.evaluation_cycle = evaluation_cycle_raw.cloneReadOnly();
    }

    isolated resource function get name() returns string? {
        lock {
                return self.evaluation_cycle.name;
        }
    }


    isolated resource function get description() returns string? {
        lock {
            return self.evaluation_cycle.description;
        }
    }

    isolated resource function get start_date() returns string? {
        lock {
            return self.evaluation_cycle.start_date;
        }
    }

    isolated resource function get end_date() returns string? {
        lock {
            return self.evaluation_cycle.end_date;
        }
    }
}
