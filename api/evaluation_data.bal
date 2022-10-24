public isolated service class EvaluationData {
    private Evaluation evaluation = {id:0, evaluatee_id: 0, evaluator_id: 0, evaluation_criteria_id: 0, grade: 0, notes: (), updated: ()};

    isolated function init(int? evaluation_id = 0, Evaluation? evaluation = null) returns error? {
        if(evaluation != null) { // if evaluation is provided, then use that and do not load from DB
            self.evaluation = evaluation.cloneReadOnly();
            return;
        }

        int id = evaluation_id ?: 0;

        if(id > 0) { // evaluation_id provided, give precedance to that
            Evaluation org_raw = check db_client -> queryRow(
            `SELECT *
            FROM avinya_db.evaluation
            WHERE
                id = ${id};`);
            self.evaluation = org_raw.cloneReadOnly();
        } 
        
    }

    isolated resource function get evaluatee_id() returns int? {
        lock {
            return self.evaluation.evaluatee_id;
        }
    }

    isolated resource function get evaluator_id() returns int? {
        lock {
            return self.evaluation.evaluator_id;
        }
    }

    isolated resource function get evaluation_criteria_id() returns int? {
        lock {
            return self.evaluation.evaluation_criteria_id;
        }
    }

    isolated resource function get updated() returns string? {
        lock {
                return self.evaluation.updated;
        }
    }

    isolated resource function get notes() returns string? {
        lock {
                return self.evaluation.notes;
        }
    }

    isolated resource function get grade() returns int? {
        lock {
                return self.evaluation.grade;
        }
    }


    isolated resource function get child_evaluations() returns EvaluationData[]|error? {
        // Get list of child evaluations
        stream<ParentChildEvaluation, error?> child_eval_ids;
        lock {
            child_eval_ids = db_client->query(
                `SELECT *
                FROM avinya_db.parent_child_evaluation
                WHERE parent_evaluation_id = ${self.evaluation.id}`
            );
        }

        EvaluationData[] child_evals = [];

        check from ParentChildEvaluation pce in child_eval_ids
            do {
                EvaluationData|error candidate_org = new EvaluationData(pce.child_evaluation_id);
                if !(candidate_org is error) {
                    child_evals.push(candidate_org);
                }
            };
        check child_eval_ids.close();
        return child_evals;
    }

    isolated resource function get parent_evaluations() returns EvaluationData[]|error? {
        // Get list of child evaluations
        stream<ParentChildEvaluation, error?> parent_evaluation_ids;
        lock {
            parent_evaluation_ids = db_client->query(
                `SELECT *
                FROM avinya_db.parent_child_evaluation
                WHERE child_evaluation_id = ${self.evaluation.id}`
            );
        }

        EvaluationData[] parent_evals = [];

        check from ParentChildEvaluation pce in parent_evaluation_ids
            do {
                EvaluationData|error candidate_org = new EvaluationData(pce.parent_evaluation_id);
                if !(candidate_org is error) {
                    parent_evals.push(candidate_org);
                }
            };
        check parent_evaluation_ids.close();
        return parent_evals;
    }

}

public isolated service class MetadataData {
    private Metadata metadata =
        {id:0, evaluation_id: 0, focus: (), is_terminal: false, level: 0, location: (), meta_type: (),
        metadata: (), on_date_time: (), status: ()};

    isolated function init(int? metadata_id = 0, Metadata? metadata = null) returns error? {
        if(metadata != null) { // if metadata is provided, then use that and do not load from DB
            self.metadata = metadata.cloneReadOnly();
            return;
        }

        int id = metadata_id ?: 0;

        if(id > 0) { // metadata_id provided, give precedance to that
            Metadata org_raw = check db_client -> queryRow(
            `SELECT *
            FROM avinya_db.metadata
            WHERE
                id = ${id};`);
            self.metadata = org_raw.cloneReadOnly();
        } 
        
    }

    isolated resource function get evaluation_id() returns int? {
        lock {
            return self.metadata.evaluation_id;
        }
    }

    isolated resource function get location() returns string? {
        lock {
            return self.metadata.location;
        }
    }

    isolated resource function get on_date_time() returns string? {
        lock {
            return self.metadata.on_date_time;
        }
    }

    isolated resource function get level() returns int? {
        lock {
                return self.metadata.level;
        }
    }

    isolated resource function get meta_type() returns string? {
        lock {
                return self.metadata.meta_type;
        }
    }

    isolated resource function get status() returns string? {
        lock {
            return self.metadata.status;
        }
    }

    isolated resource function get focus() returns string? {
        lock {
                return self.metadata.focus;
        }
    }

    isolated resource function get metadata() returns string? {
        lock {
                return self.metadata.metadata;
        }
    }
    isolated resource function get is_terminal() returns boolean? {
        lock {
                return self.metadata.is_terminal;
        }
    }

}
