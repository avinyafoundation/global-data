public isolated service class ActivityInstanceEvaluationData {

    private ActivityInstanceEvaluation activity_instance_evaluation;

    isolated function init(int? id = 0, ActivityInstanceEvaluation? activity_instance_evaluation = null) returns error? {

        if (activity_instance_evaluation != null) {
            self.activity_instance_evaluation = activity_instance_evaluation.cloneReadOnly();
            return;
        }

        lock {

            ActivityInstanceEvaluation activity_instance_evaluation_raw;

            if (id > 0) {

                activity_instance_evaluation_raw = check db_client->queryRow(
                                    `SELECT *
                                    FROM activity_instance_evaluation
                                    WHERE id = ${id};`
                                );

            } else {
                return error("No id provided");
            }

            self.activity_instance_evaluation = activity_instance_evaluation_raw.cloneReadOnly();
        }
    }

    isolated resource function get id() returns int?|error {
        lock {
            return self.activity_instance_evaluation.id;
        }
    }

    isolated resource function get activity_instance_id() returns int?|error {
        lock {
            return self.activity_instance_evaluation.activity_instance_id;
        }
    }

    isolated resource function get evaluator_id() returns int?|error {
        lock {
            return self.activity_instance_evaluation.evaluator_id;
        }
    }

    isolated resource function get feedback() returns string?|error {
        lock {
            return self.activity_instance_evaluation.feedback;
        }
    }

    isolated resource function get rating() returns int?|error {
        lock {
            return self.activity_instance_evaluation.rating;
        }
    }

    isolated resource function get created() returns string?|error {
        lock {
            return self.activity_instance_evaluation.created;
        }
    }

    isolated resource function get updated() returns string?|error {
        lock {
            return self.activity_instance_evaluation.updated;
        }
    }
}
