public isolated service class WorkExperienceData {
    private WorkExperience work_experience = {id: 0, person_id: 0, end_date: (), start_date: (), organization: ()};

    isolated function init(int? work_experience_id = 0, WorkExperience? work_experience = null) returns error? {
        if(work_experience != null) { // if work_experience is provided, then use that and do not load from DB
            self.work_experience = work_experience.cloneReadOnly();
            return;
        }

        int id = work_experience_id ?: 0;

        if(id > 0) { // work_experience_id provided, give precedance to that
            WorkExperience org_raw = check db_client -> queryRow(
            `SELECT *
            FROM avinya_db.work_experience
            WHERE
                id = ${id};`);
            self.work_experience = org_raw.cloneReadOnly();

        } 
        
    }

    isolated resource function get person_id() returns int? {
        lock {
            return self.work_experience.person_id;
        }
    }

    isolated resource function get organization() returns string? {
        lock {
                return self.work_experience.organization;
        }
    }

    isolated resource function get start_date() returns string? {
        lock {
                return self.work_experience.start_date;
        }
    }

    isolated resource function get end_date() returns string? {
        lock {
                return self.work_experience.end_date;
        }
    }

}

public isolated service class WorkExperienceEvaluationData {
    private WorkExperienceEvaluation work_experience_evaluation = {work_experience_id: 0, evaluation_id: 0};

    isolated function init(int? work_experience_evaluation_id = 0, WorkExperienceEvaluation? work_experience_evaluation = null) returns error? {
        if(work_experience_evaluation != null) { // if work_experience_evaluation is provided, then use that and do not load from DB
            self.work_experience_evaluation = work_experience_evaluation.cloneReadOnly();
            return;
        }

        int id = work_experience_evaluation_id ?: 0;

        if(id > 0) { // work_experience_evaluation_id provided, give precedance to that
            WorkExperienceEvaluation org_raw = check db_client -> queryRow(
            `SELECT *
            FROM avinya_db.work_experience_evaluation
            WHERE
                id = ${id};`);
            self.work_experience_evaluation = org_raw.cloneReadOnly();
        } 
        
    }

    isolated resource function get work_experience_id() returns int? {
        lock {
            return self.work_experience_evaluation.work_experience_id;
        }
    }

    isolated resource function get evaluation_id() returns int? {
        lock {
            return self.work_experience_evaluation.evaluation_id;
        }
    }

}
