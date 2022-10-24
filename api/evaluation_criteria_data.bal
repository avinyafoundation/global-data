public isolated service class EvaluationCriteriaData {
    private EvaluationCriteria evaluation_criteria;

    isolated function init(string? prompt = null, int? evaluation_criteria_id = 0, EvaluationCriteria? evaluation_criteria = null) returns error? {
        if(evaluation_criteria != null) { // if evaluation_criteria is provided, then use that and do not load from DB
            self.evaluation_criteria = evaluation_criteria.cloneReadOnly();
            return;
        }

        string _prompt = "%" + (prompt ?: "") + "%";
        int id = evaluation_criteria_id ?: 0;

        EvaluationCriteria org_raw;
        if(id > 0) { // evaluation_criteria_id provided, give precedance to that
            org_raw = check db_client -> queryRow(
            `SELECT *
            FROM avinya_db.evaluation_criteria
            WHERE
                id = ${id};`);
        } else 
        {
            org_raw = check db_client -> queryRow(
            `SELECT *
            FROM avinya_db.evaluation_criteria
            WHERE
                prompt LIKE ${_prompt};`);
        }
        
        self.evaluation_criteria = org_raw.cloneReadOnly();
    }

    isolated resource function get prompt() returns string? {
        lock {
                return self.evaluation_criteria.prompt;
        }
    }


    isolated resource function get description() returns string? {
        lock {
            return self.evaluation_criteria.description;
        }
    }

    isolated resource function get expected_answer() returns string? {
        lock {
            return self.evaluation_criteria.expected_answer;
        }
    }

    isolated resource function get evalualtion_type() returns string? {
        lock {
            return self.evaluation_criteria.evalualtion_type;
        }
    }

    isolated resource function get difficulty() returns string? {
        lock {
            return self.evaluation_criteria.difficulty;
        }
    }

    isolated resource function get rating_out_of() returns int? {
        lock {
            return self.evaluation_criteria.rating_out_of;
        }
    }

    isolated resource function get answer_options() returns EvaluationCriteriaAnswerOptionData[]|error? {
        // Get list of child organizations
        stream<EvaluationCriteriaAnswerOption, error?> answer_options;
        lock {
            answer_options = db_client->query(
                `SELECT *
                FROM avinya_db.evaluation_criteria_answer_option
                WHERE evaluation_criteria_id = ${self.evaluation_criteria.id}`
            );
        }

        EvaluationCriteriaAnswerOptionData[] answer_options_data = [];

        check from EvaluationCriteriaAnswerOption answer_option in answer_options
            do {
                EvaluationCriteriaAnswerOptionData|error answer_option_data = new EvaluationCriteriaAnswerOptionData((), 0, answer_option);
                if !(answer_option_data is error) {
                    answer_options_data.push(answer_option_data);
                }
            };

        check answer_options.close();
        
        return answer_options_data;
    }
}


public isolated service class EvaluationCriteriaAnswerOptionData {
    private EvaluationCriteriaAnswerOption evaluation_criteria_answer_option;

    isolated function init(string? answer = null, int? evaluation_criteria_answer_option_id = 0, EvaluationCriteriaAnswerOption? evaluation_criteria_answer_option = null) returns error? {
        if(evaluation_criteria_answer_option != null) { // if evaluation_criteria_answer_option is provided, then use that and do not load from DB
            self.evaluation_criteria_answer_option = evaluation_criteria_answer_option.cloneReadOnly();
            return;
        }

        string _answer = "%" + (answer ?: "") + "%";
        int id = evaluation_criteria_answer_option_id ?: 0;

        EvaluationCriteriaAnswerOption org_raw;
        if(id > 0) { // evaluation_criteria_answer_option_id provided, give precedance to that
            org_raw = check db_client -> queryRow(
            `SELECT *
            FROM avinya_db.evaluation_criteria_answer_option
            WHERE
                id = ${id};`);
        } else 
        {
            org_raw = check db_client -> queryRow(
            `SELECT *
            FROM avinya_db.evaluation_criteria_answer_option
            WHERE
                answer LIKE ${_answer};`);
        }
        
        self.evaluation_criteria_answer_option = org_raw.cloneReadOnly();
    }

    isolated resource function get answer() returns string? {
        lock {
                return self.evaluation_criteria_answer_option.answer;
        }
    }


    isolated resource function get expected_answer() returns boolean? {
        lock {
            return self.evaluation_criteria_answer_option.expected_answer;
        }
    }

    isolated resource function get evaluation_criteria_id() returns int? {
        lock {
            return self.evaluation_criteria_answer_option.evaluation_criteria_id;
        }
    }
}
