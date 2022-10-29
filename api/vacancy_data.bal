public isolated service class VacancyData {
    private Vacancy vacancy;

    isolated function init(string? name = null, int? vacancy_id = 0, Vacancy? vacancy = null) returns error? {
        if(vacancy != null) { // if vacancy is provided, then use that and do not load from DB
            self.vacancy = vacancy.cloneReadOnly();
            return;
        }

        string _name = "%" + (name ?: "") + "%";
        int id = vacancy_id ?: 0;

        Vacancy org_raw;
        if(id > 0) { // vacancy_id provided, give precedance to that
            org_raw = check db_client -> queryRow(
            `SELECT *
            FROM avinya_db.vacancy
            WHERE
                id = ${id};`);
        } else 
        {
            org_raw = check db_client -> queryRow(
            `SELECT *
            FROM avinya_db.vacancy
            WHERE
                name LIKE ${_name};`);
        }
        
        self.vacancy = org_raw.cloneReadOnly();
    }

    isolated resource function get id() returns int? {
        lock {
                return self.vacancy.id;
        }
    }

    isolated resource function get name() returns string? {
        lock {
                return self.vacancy.name;
        }
    }

    isolated resource function get avinya_type() returns AvinyaTypeData|error? {
        int id = 0;
        lock {
            id = self.vacancy.avinya_type_id ?: 0;
            if( id == 0) {
                return null; // no point in querying if address id is null
            } 
        }
        
        return new AvinyaTypeData(id);
    }

    isolated resource function get description() returns string? {
        lock {
            return self.vacancy.description;
        }
    }

    isolated resource function get head_count() returns int? {
        lock {
            return self.vacancy.head_count;
        }
    }

    isolated resource function get evaluation_criteria() returns EvaluationCriteriaData[]|error? {
        EvaluationCriteriaData[] evaluationCriteriaData = [];

        // get all admissions test evaluation criteria for this vacancy
        // 2 essays 4 easy MCQ, 4 medium MCQ and 2 hard MCQ, 
        // this is specifc to student admission test
        // for other vacancies, this will be different 
        // so we need to pick the criterial from type when you 
        // select from the database
        // that is TODO logic

        stream<EvaluationCriteria, error?> evaluation_criteria;
        lock {
            evaluation_criteria = db_client->query(
                `SELECT *
                FROM avinya_db.evaluation_criteria
                WHERE evalualtion_type = 'Essay' AND id IN 
                (SELECT evaluation_criteria_id FROM vacancy_evaluation_criteria 
	                WHERE vacancy_id = ${self.vacancy.id});`
            );
        }

        check from EvaluationCriteria evaluation_criterion in evaluation_criteria
            do {
                EvaluationCriteriaData|error evaluationCriterionData = new EvaluationCriteriaData((), 0, evaluation_criterion);
                if !(evaluationCriterionData is error) {
                    evaluationCriteriaData.push(evaluationCriterionData);
                }
            };
        
        check evaluation_criteria.close();

        // Get list of people in the organization
        lock {
            evaluation_criteria = db_client->query(
                `SELECT *
                FROM avinya_db.evaluation_criteria
                WHERE evalualtion_type = 'Multiple Choice' AND 
                difficulty = 'Easy' AND id IN 
                (SELECT evaluation_criteria_id FROM vacancy_evaluation_criteria 
	                WHERE vacancy_id = ${self.vacancy.id})
                ORDER BY RAND() LIMIT 4;`
            );
        }

        

        check from EvaluationCriteria evaluation_criterion in evaluation_criteria
            do {
                EvaluationCriteriaData|error evaluationCriterionData = new EvaluationCriteriaData((), 0, evaluation_criterion);
                if !(evaluationCriterionData is error) {
                    evaluationCriteriaData.push(evaluationCriterionData);
                }
            };
        
        check evaluation_criteria.close();

        lock {
            evaluation_criteria = db_client->query(
                `SELECT *
                FROM avinya_db.evaluation_criteria
                WHERE evalualtion_type = 'Multiple Choice' AND 
                difficulty = 'Medium' AND id IN 
                (SELECT evaluation_criteria_id FROM vacancy_evaluation_criteria 
	                WHERE vacancy_id = ${self.vacancy.id})
                ORDER BY RAND() LIMIT 4;`
            );
        }

        check from EvaluationCriteria evaluation_criterion in evaluation_criteria
            do {
                EvaluationCriteriaData|error evaluationCriterionData = new EvaluationCriteriaData((), 0, evaluation_criterion);
                if !(evaluationCriterionData is error) {
                    evaluationCriteriaData.push(evaluationCriterionData);
                }
            };

        check evaluation_criteria.close();

        lock {
            evaluation_criteria = db_client->query(
                `SELECT *
                FROM avinya_db.evaluation_criteria
                WHERE evalualtion_type = 'Multiple Choice' AND 
                difficulty = 'Hard' AND id IN 
                (SELECT evaluation_criteria_id FROM vacancy_evaluation_criteria 
	                WHERE vacancy_id = ${self.vacancy.id})
                ORDER BY RAND() LIMIT 2;`
            );
        }

        check from EvaluationCriteria evaluation_criterion in evaluation_criteria
            do {
                EvaluationCriteriaData|error evaluationCriterionData = new EvaluationCriteriaData((), 0, evaluation_criterion);
                if !(evaluationCriterionData is error) {
                    evaluationCriteriaData.push(evaluationCriterionData);
                }
            };

        check evaluation_criteria.close();

        return evaluationCriteriaData;
    }
}
