public isolated service class EducationExperienceData {
    private EducationExperience education_experience = {id: 0, person_id: 0, end_date: (), start_date: (), school: ()};

    isolated function init(int? education_experience_id = 0, int? person_id = 0, EducationExperience? education_experience = null) returns error? {
        if (education_experience != null) { // if education_experience is provided, then use that and do not load from DB
            self.education_experience = education_experience.cloneReadOnly();
            return;
        }

        int id = education_experience_id ?: 0;
        lock {
            EducationExperience education_experience_raw;
            if (id > 0 && person_id == 0) { // education_experience_id provided, give precedance to that
                education_experience_raw = check db_client->queryRow(
            `SELECT *
            FROM education_experience
            WHERE
                id = ${id};`);

            } else {
                education_experience_raw = check db_client->queryRow(
            `SELECT *
            FROM education_experience
            WHERE
                person_id = ${person_id};`);
            }
            self.education_experience = education_experience_raw.cloneReadOnly();
        }
    }

    isolated resource function get person_id() returns int? {
        lock {
            return self.education_experience.person_id;
        }
    }

    isolated resource function get school() returns string? {
        lock {
            return self.education_experience.school;
        }
    }

    isolated resource function get start_date() returns string? {
        lock {
            return self.education_experience.start_date;
        }
    }

    isolated resource function get end_date() returns string? {
        lock {
            return self.education_experience.end_date;
        }
    }

    isolated resource function get education_evaluations() returns EducationExperienceData[]|error? {
        // Get list of child evaluations
        stream<EducationExperienceEvaluation, error?> education_eval_ids;
        lock {
            education_eval_ids = db_client->query(
                `SELECT *
                FROM education_experience_evaluation
                WHERE education_experience_id = ${self.education_experience.id}`
            );
        }

        EducationExperienceData[] education_evals = [];

        check from EducationExperienceEvaluation pce in education_eval_ids
            do {
                EducationExperienceData|error candidate_org = new EducationExperienceData(pce.evaluation_id);
                if !(candidate_org is error) {
                    education_evals.push(candidate_org);
                }
            };
        check education_eval_ids.close();
        return education_evals;
    }

}

public isolated service class EducationExperienceEvaluationData {
    private EducationExperienceEvaluation education_experience_evaluation = {education_experience_id: 0, evaluation_id: 0};

    isolated function init(int? education_experience_evaluation_id = 0, EducationExperienceEvaluation? education_experience_evaluation = null) returns error? {
        if (education_experience_evaluation != null) { // if education_experience_evaluation is provided, then use that and do not load from DB
            self.education_experience_evaluation = education_experience_evaluation.cloneReadOnly();
            return;
        }

        int id = education_experience_evaluation_id ?: 0;

        if (id > 0) { // education_experience_evaluation_id provided, give precedance to that
            EducationExperienceEvaluation education_experience_raw = check db_client->queryRow(
            `SELECT *
            FROM education_experience_evaluation
            WHERE
                id = ${id};`);
            self.education_experience_evaluation = education_experience_raw.cloneReadOnly();
        }

    }

    isolated resource function get education_experience_id() returns int? {
        lock {
            return self.education_experience_evaluation.education_experience_id;
        }
    }

    isolated resource function get evaluation_id() returns int? {
        lock {
            return self.education_experience_evaluation.evaluation_id;
        }
    }

}
