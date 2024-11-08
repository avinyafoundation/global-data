import ballerina/graphql;
import ballerina/io;
import ballerina/log;
import ballerina/sql;
import ballerina/time;

// @display {
//     label: "Global Data API",
//     id: "global-data"
// }
service /graphql on new graphql:Listener(4000) {
    resource function get geo() returns GeoData {
        return new ();
    }

    resource function get avinya_types() returns AvinyaTypeData[]|error {
        stream<AvinyaType, error?> avinyaTypes;
        lock {
            avinyaTypes = db_client->query(
                `SELECT *
                FROM avinya_type`
            );
        }

        AvinyaTypeData[] avinyaTypeDatas = [];

        check from AvinyaType avinyaType in avinyaTypes
            do {
                AvinyaTypeData|error avinyaTypeData = new AvinyaTypeData(0, avinyaType);
                if !(avinyaTypeData is error) {
                    avinyaTypeDatas.push(avinyaTypeData);
                }
            };

        check avinyaTypes.close();
        return avinyaTypeDatas;
    }

    remote function add_avinya_type(AvinyaType avinya_type) returns AvinyaTypeData|error? {
        sql:ExecutionResult res = check db_client->execute(
            `INSERT INTO avinya_type (
                global_type,
                foundation_type,
                focus,
                active,
                name,
                description,
                level
            ) VALUES (
                ${avinya_type.global_type},
                ${avinya_type.foundation_type},
                ${avinya_type.focus},
                ${avinya_type.active},
                ${avinya_type.name},
                ${avinya_type.description},
                ${avinya_type.level}
            );`
        );

        int|string? insert_id = res.lastInsertId;
        if !(insert_id is int) {
            return error("Unable to insert Avinya Type");
        }

        return new (insert_id);
    }

    remote function update_avinya_type(AvinyaType avinya_type) returns AvinyaTypeData|error? {
        int id = avinya_type.id ?: 0;
        if (id == 0) {
            return error("Unable to update Avinya Type");
        }

        sql:ExecutionResult res = check db_client->execute(
            `UPDATE avinya_type SET
                global_type = ${avinya_type.global_type},
                foundation_type = ${avinya_type.foundation_type},
                focus = ${avinya_type.focus},
                active = ${avinya_type.active},
                name = ${avinya_type.name},
                description = ${avinya_type.description},
                level = ${avinya_type.level}
            WHERE id = ${id};`
        );

        if (res.affectedRowCount == sql:EXECUTION_FAILED) {
            return error("Unable to update Avinya Type");
        }

        return new (id);
    }

    isolated resource function get organization_structure(string? name, int? id) returns OrganizationStructureData|error? {
        return new (name, id);
    }

    isolated resource function get organizations(int level) returns OrganizationStructureData|error? {
        return new (level = level);
    }

    isolated resource function get organization(string? name, int? id) returns OrganizationData|error? {
        return new (name, id);
    }

    isolated resource function get organizations_by_avinya_type(int? avinya_type, int? active = 0) returns OrganizationData[]|error? {

        stream<Organization, error?> org_list;

        if (active == 1) {

            lock {
                org_list = db_client->query(
                    `SELECT *
                    FROM organization
                    WHERE avinya_type = ${avinya_type} and active = ${active}`);
            }

        } else {

            lock {
                org_list = db_client->query(
                `SELECT *
	             FROM organization
	             WHERE avinya_type = ${avinya_type}
                `
            );
            }

        }

        OrganizationData[] organizationListDatas = [];

        check from Organization organization in org_list
            do {
                OrganizationData|error organizationData = new OrganizationData((), (), organization);
                if !(organizationData is error) {
                    organizationListDatas.push(organizationData);
                }
            };

        check org_list.close();
        return organizationListDatas;
    }

    isolated resource function get student_list_by_parent(int? id) returns PersonData[]|error? {
        stream<Person, error?> studentList;
        lock {
            studentList = db_client->query(
                `SELECT * FROM person WHERE avinya_type_id IN (37, 10, 96) AND organization_id in
                (SELECT child_org_id FROM parent_child_organization WHERE parent_org_id IN
                (SELECT organization_id FROM organization_metadata WHERE organization_id IN
                (SELECT id FROM organization WHERE id in (SELECT child_org_id FROM parent_child_organization WHERE parent_org_id = 2 ) AND avinya_type = 86)
                AND organization_id IN (SELECT organization_id FROM organization_metadata WHERE key_name = 'start_date' AND CURRENT_DATE() >= value)
                AND organization_id IN (SELECT organization_id FROM organization_metadata WHERE key_name = 'end_date' AND CURRENT_DATE() <= value)));`
            );
        }

        PersonData[] studentListDatas = [];

        check from Person student in studentList
            do {
                PersonData|error studentData = new PersonData((), (), student);
                if !(studentData is error) {
                    studentListDatas.push(studentData);
                }
            };

        check studentList.close();
        return studentListDatas;
    }

    isolated resource function get person(string? name, int? id) returns PersonData|error? {
        return new (name, id);
    }

    isolated resource function get person_by_digital_id(string? id) returns PersonData|error? {

        Person|error? personJwtId = check db_client->queryRow(
            `SELECT *
            FROM person
            WHERE digital_id = ${id};`
        );

        if (personJwtId is Person) {
            return new ((), 0, personJwtId);
        }
        return error("Unable to find person by digital id");
    }

    isolated resource function get prospect(string? email, int? phone) returns ProspectData|error? {
        return new (email, phone);
    }

    isolated resource function get applicant_consent(string? email, int? phone) returns ApplicantConsentData|error? {
        return new (email, phone);
    }

    isolated resource function get application(int person_id) returns ApplicationData|error? {
        return new (0, person_id);
    }

    isolated resource function get evaluation(int eval_id) returns EvaluationData|error? {
        return new (eval_id);
    }

    isolated resource function get pcti_activities() returns ActivityData[]|error? {
        stream<Activity, error?> pctiActivities;
        lock {
            pctiActivities = db_client->query(
                ` SELECT *
                FROM activity
                WHERE activity.avinya_type_id IN 
                (SELECT avinya_type.id
                FROM avinya_type
                WHERE name = "pcti");`
            );
        }

        ActivityData[] pctiActivityDatas = [];

        check from Activity pctiActivity in pctiActivities
            do {
                ActivityData|error pctiActivityData = new ActivityData((), (), (), pctiActivity);
                if !(pctiActivityData is error) {
                    pctiActivityDatas.push(pctiActivityData);
                }
            };

        check pctiActivities.close();
        return pctiActivityDatas;
    }

    // will return notes of a PCTI instance
    isolated resource function get pcti_instance_notes(int pcti_instance_id) returns EvaluationData[]|error? {
        stream<Evaluation, error?> pctiNotes;
        lock {
            pctiNotes = db_client->query(
                `SELECT *
                FROM evaluation
                WHERE activity_instance_id = ${pcti_instance_id}`
            );
        }

        EvaluationData[] pctiNotesData = [];

        check from Evaluation pctiNote in pctiNotes
            do {
                EvaluationData|error pctiNoteData = new EvaluationData(0, pctiNote);
                if !(pctiNoteData is error) {
                    pctiNotesData.push(pctiNoteData);
                }
            };

        check pctiNotes.close();
        return pctiNotesData;

    }

    // will return notes of a Project Class activity
    // note pcti_id is the activity (child activity of Project and Class parents)
    isolated resource function get pcti_activity_notes(int pcti_activity_id) returns EvaluationData[]|error? {
        stream<Evaluation, error?> pctiEvaluations;
        lock {
            pctiEvaluations = db_client->query(
                `SELECT 
                    e.id,
                    evaluatee_id,
                    evaluator_id,
                    evaluation_criteria_id,
                    e.activity_instance_id,
                    response,
                    e.notes,
                    grade,
                    e.updated
                FROM
                    evaluation e
                        JOIN
                    activity_instance ai ON e.activity_instance_id = ai.id
                        JOIN
                    activity a ON ai.activity_id = a.id
                WHERE
                    activity_id = ${pcti_activity_id};`
            );
        }

        EvaluationData[] pctiEvaluationsData = [];

        check from Evaluation pctiEvaluation in pctiEvaluations
            do {
                EvaluationData|error pctiEvaluationData = new EvaluationData((), pctiEvaluation);
                if !(pctiEvaluationData is error) {
                    pctiEvaluationsData.push(pctiEvaluationData);
                }
            };

        check pctiEvaluations.close();
        return pctiEvaluationsData;

    }

    // get pcti_activity
    isolated resource function get pcti_activity(string project_activity_name, string class_activity_name) returns ActivityData|error? {
        Activity|error? projectActivityRaw = db_client->queryRow(
            `SELECT *
            FROM activity
            WHERE name = ${project_activity_name};`
        );

        if !(projectActivityRaw is Activity) {
            return error("Project does not exist");
        }

        Activity|error? classActivityRaw = db_client->queryRow(
            `SELECT *
            FROM activity
            WHERE name = ${class_activity_name};`
        );

        if !(classActivityRaw is Activity) {
            return error("Class does not exist");
        }

        Activity|error? pctiActivityRaw = db_client->queryRow(
            `SELECT A.*
            FROM activity A
            INNER JOIN parent_child_activity PCA1 ON A.id = PCA1.child_activity_id AND PCA1.parent_activity_id = ${projectActivityRaw.id}
            INNER JOIN parent_child_activity PCA2 ON A.id = PCA2.child_activity_id AND PCA2.parent_activity_id = ${classActivityRaw.id};`
        );

        if (pctiActivityRaw is Activity) {
            return new ((), pctiActivityRaw.id);
        }

        return error("PCTI activity does not exist");
    }

    isolated resource function get pcti_project_activities(string teacher_id) returns ActivityData[]|error? {
        stream<Activity, error?> pctiProjectActivities;
        lock {
            pctiProjectActivities = db_client->query(
                `SELECT A.*
                FROM activity A
                INNER JOIN parent_child_activity PCA ON A.id = PCA.child_activity_id
                INNER JOIN activity B ON PCA.parent_activity_id = B.id
                WHERE B.name = "Project" AND A.teacher_id = ${teacher_id};`
            );
        }

        ActivityData[] pctiProjectActivitiesData = [];

        check from Activity pctiProjectActivity in pctiProjectActivities
            do {
                ActivityData|error pctiProjectActivityData = new ActivityData((), pctiProjectActivity.id);
                if !(pctiProjectActivityData is error) {
                    pctiProjectActivitiesData.push(pctiProjectActivityData);
                }
            };

        check pctiProjectActivities.close();
        return pctiProjectActivitiesData;
    }

    // gets the pcti activities attended by a person
    isolated resource function get pcti_participant_activities(int participant_id) returns ActivityData[]|error? {
        stream<Activity, error?> pctiParticipantActivities;
        lock {
            pctiParticipantActivities = db_client->query(
                `SELECT DISTINCT a.*
                FROM activity a
                JOIN parent_child_activity pca ON a.id = pca.child_activity_id
                JOIN activity parent_activity ON pca.parent_activity_id = parent_activity.id
                JOIN avinya_type at ON parent_activity.avinya_type_id = at.id AND at.name = 'group-project'
                JOIN (
                SELECT DISTINCT ai.*
                FROM activity_instance ai
                JOIN activity_participant ap ON ai.id = ap.activity_instance_id
                JOIN (
                    SELECT o.*
                    FROM organization o
                    JOIN avinya_type at ON o.avinya_type = at.id
                    WHERE at.name = 'homeroom'
                ) o ON ai.organization_id = o.id
                WHERE ap.person_id = ${participant_id}
                ) ai ON a.id = ai.activity_id;`
            );
        }

        ActivityData[] pctiParticipantActivitiesData = [];

        check from Activity pctiParticipantActivity in pctiParticipantActivities
            do {
                ActivityData|error pctiParticipantActivityData = new ActivityData((), pctiParticipantActivity.id);
                if !(pctiParticipantActivityData is error) {
                    pctiParticipantActivitiesData.push(pctiParticipantActivityData);
                }
            };

        check pctiParticipantActivities.close();
        return pctiParticipantActivitiesData;
    }

    isolated resource function get activity_instances_today(int activity_id) returns ActivityInstanceData[]|error? {
        // first check if activity instances for today are already created
        ActivityInstance|error todayActitivutyInstance = db_client->queryRow(
            `SELECT *
            FROM activity_instance
            WHERE DATE(start_time) = CURDATE();`
        );

        // if not, create them
        if !(todayActitivutyInstance is ActivityInstance) {
            log:printError("No activity instance today");
            log:printInfo("Creating activity instances for today");

            sql:ExecutionResult res = check db_client->execute(
            `INSERT INTO activity_instance (activity_id, name, daily_sequence, start_time, end_time) VALUES
                (1, "School Day", 1, DATE_ADD(CURDATE(), INTERVAL '7:00' HOUR_MINUTE), DATE_ADD(CURDATE(), INTERVAL '16:30' HOUR_MINUTE)),
                (2, "Daily Arrival", 2, DATE_ADD(CURDATE(), INTERVAL '7:00' HOUR_MINUTE), DATE_ADD(CURDATE(), INTERVAL '8:00' HOUR_MINUTE)),
                (3, "Daily Breakfast", 3, DATE_ADD(CURDATE(), INTERVAL '8:00' HOUR_MINUTE), DATE_ADD(CURDATE(), INTERVAL '8:30' HOUR_MINUTE)),
                (4, "Daily Homeroom", 4, DATE_ADD(CURDATE(), INTERVAL '8:30' HOUR_MINUTE), DATE_ADD(CURDATE(), INTERVAL '9:00' HOUR_MINUTE)),
                (5, "Daily PCTI 1", 5, DATE_ADD(CURDATE(), INTERVAL '9:00' HOUR_MINUTE), DATE_ADD(CURDATE(), INTERVAL '11:00' HOUR_MINUTE)),
                (8, "Daily Tea Break", 6, DATE_ADD(CURDATE(), INTERVAL '11:00' HOUR_MINUTE), DATE_ADD(CURDATE(), INTERVAL '11:30' HOUR_MINUTE)),
                (5, "Daily PCTI 2", 7, DATE_ADD(CURDATE(), INTERVAL '11:30' HOUR_MINUTE), DATE_ADD(CURDATE(), INTERVAL '13:00' HOUR_MINUTE)),
                (10, "Daily Lunch", 8, DATE_ADD(CURDATE(), INTERVAL '13:00' HOUR_MINUTE), DATE_ADD(CURDATE(), INTERVAL '13:45' HOUR_MINUTE)),
                (9, "Daily Free Time", 9, DATE_ADD(CURDATE(), INTERVAL '13:45' HOUR_MINUTE), DATE_ADD(CURDATE(), INTERVAL '14:15' HOUR_MINUTE)),
                (11, "Daily Work", 10, DATE_ADD(CURDATE(), INTERVAL '14:15' HOUR_MINUTE), DATE_ADD(CURDATE(), INTERVAL '15:00' HOUR_MINUTE)),
                (12, "Daily Departure", 11, DATE_ADD(CURDATE(), INTERVAL '15:00' HOUR_MINUTE), DATE_ADD(CURDATE(), INTERVAL '16:30' HOUR_MINUTE)),
                (13, "Daily After School", 12, DATE_ADD(CURDATE(), INTERVAL '15:00' HOUR_MINUTE), DATE_ADD(CURDATE(), INTERVAL '16:30' HOUR_MINUTE));`
            );

            int|string? insert_id = res.lastInsertId;
            if !(insert_id is int) {
                return error("Unable to create activity instances for today");
            }

            // duty participants rotation cycle code block[425 line to 431 line]
            var updateResult = updateDutyParticipantsRotationCycle();

            if (updateResult is error) {
                log:printError("Error updating Rotation Cycle of duty participants: ", updateResult);
            } else {
                log:printInfo("Duty participants Rotation Cycle updated successfully");
            }

        }

        // now move on to finding the activity instances for today for given activity id
        stream<ActivityInstance, error?> pctiActivityInstancesToday;
        lock {
            pctiActivityInstancesToday = db_client->query(
                `SELECT *
                FROM activity_instance
                WHERE activity_id = ${activity_id} AND
                DATE(start_time) = CURDATE();`
            );
        }

        ActivityInstanceData[] pctiActivityInstancesTodayData = [];

        check from ActivityInstance pctiActivityInstanceToday in pctiActivityInstancesToday
            do {
                ActivityInstanceData|error pctiActivityInstanceTodayData = new ActivityInstanceData((), pctiActivityInstanceToday.id);
                if !(pctiActivityInstanceTodayData is error) {
                    pctiActivityInstancesTodayData.push(pctiActivityInstanceTodayData);
                }
            };

        check pctiActivityInstancesToday.close();

        if (pctiActivityInstancesTodayData.length() == 0) {
            log:printError("No activity instances for today");
        }

        return pctiActivityInstancesTodayData;
    }

    isolated resource function get activity_instances_future(int activity_id) returns ActivityInstanceData[]|error? {
        stream<ActivityInstance, error?> activityInstancesFuture;
        lock {
            activityInstancesFuture = db_client->query(
                `SELECT *
                FROM activity_instance
                WHERE activity_id = ${activity_id} AND
                DATE(start_time) >= CURDATE();`
            );
        }

        ActivityInstanceData[] activityInstancesFutureData = [];

        check from ActivityInstance activityInstanceFuture in activityInstancesFuture
            do {
                ActivityInstanceData|error activityInstanceFutureData = new ActivityInstanceData((), activityInstanceFuture.id);
                if !(activityInstanceFutureData is error) {
                    activityInstancesFutureData.push(activityInstanceFutureData);
                }
            };

        check activityInstancesFuture.close();
        return activityInstancesFutureData;
    }

    isolated resource function get available_teachers(int activity_instance_id) returns PersonData[]|error? {
        stream<Person, error?> availableTeachers;
        lock {
            availableTeachers = db_client->query(
                `SELECT DISTINCT person.*
                FROM person
                LEFT JOIN activity_participant ON person.id = activity_participant.person_id
                LEFT JOIN activity_instance ON activity_participant.activity_instance_id = activity_instance.id
                INNER JOIN avinya_type ON person.avinya_type_id = avinya_type.id
                WHERE avinya_type.name = 'bootcamp-teacher'
                AND (
                activity_participant.activity_instance_id IS NULL
                OR (
                    activity_instance.start_time > (SELECT end_time FROM activity_instance WHERE id = ${activity_instance_id})
                    OR activity_instance.end_time < (SELECT start_time FROM activity_instance WHERE id = ${activity_instance_id}))
                )`
            );
        }

        PersonData[] availableTeachersData = [];

        check from Person availableTeacher in availableTeachers
            do {
                PersonData|error availableTeacherData = new PersonData((), availableTeacher.id);
                if !(availableTeacherData is error) {
                    availableTeachersData.push(availableTeacherData);
                }
            };

        check availableTeachers.close();
        return availableTeachersData;
    }

    isolated resource function get project_tasks(int activity_id) returns ActivityData[]|error? {
        stream<Activity, error?> projectTasks;
        lock {
            projectTasks = db_client->query(
                `SELECT a.*
                FROM activity a
                JOIN avinya_type at ON a.avinya_type_id = at.id
                JOIN parent_child_activity pca ON a.id = pca.child_activity_id
                WHERE at.name = 'project-task'
                AND pca.parent_activity_id = ${activity_id};`
            );
        }

        ActivityData[] projectTasksData = [];

        check from Activity projectTask in projectTasks
            do {
                ActivityData|error projectTaskData = new ActivityData((), projectTask.id);
                if !(projectTaskData is error) {
                    projectTasksData.push(projectTaskData);
                }
            };

        check projectTasks.close();
        return projectTasksData;
    }

    isolated resource function get student_applicant(string? jwt_sub_id) returns PersonData|error? {
        AvinyaType avinya_type_raw = check db_client->queryRow(
            `SELECT *
            FROM avinya_type
            WHERE global_type = "applicant" AND  foundation_type = "student";`
        );

        Person|error? applicantRaw = db_client->queryRow(
            `SELECT *
            FROM person
            WHERE jwt_sub_id = ${jwt_sub_id} AND 
            avinya_type_id = ${avinya_type_raw.id};`
        );

        if (applicantRaw is Person) {
            return new ((), applicantRaw.id);
        }

        return error("Applicant does not exist for given sub id: " + (jwt_sub_id ?: ""));

    }

    remote function add_educator_applicant(Person person) returns PersonData|error? {

        AvinyaType avinya_type_raw = check db_client->queryRow(
            `SELECT *
            FROM avinya_type
            WHERE global_type = "applicant" AND  foundation_type = "educator";`
        );

        Person|error? applicantRaw = db_client->queryRow(
            `SELECT *
            FROM person
            WHERE (email = ${person.email}  OR
            phone = ${person.phone} OR 
            jwt_sub_id = ${person.jwt_sub_id}) AND 
            avinya_type_id = ${avinya_type_raw.id};`
        );

        if (applicantRaw is Person) {
            return error("Applicant already exists. The phone, email or the social login account you are using is already used by another applicant");
        }

        sql:ExecutionResult|error res = db_client->execute(
            `INSERT INTO person (
                preferred_name,
                full_name,
                sex,
                organization_id,
                phone,
                email,
                avinya_type_id,
                permanent_address_id,
                mailing_address_id,
                jwt_sub_id,
                jwt_email
            ) VALUES (
                ${person.preferred_name},
                ${person.full_name},
                ${person.sex},
                ${person.organization_id},
                ${person.phone},
                ${person.email},
                ${avinya_type_raw.id},
                ${person.permanent_address_id},
                ${person.mailing_address_id},
                ${person.jwt_sub_id},
                ${person.jwt_email}
            );`
        );

        if (res is sql:ExecutionResult) {

            int|string? insert_id = res.lastInsertId;
            if !(insert_id is int) {
                return error("Unable to insert application");
            }

            return new ((), insert_id);
        }

        return error("Error while inserting data", res);

    }

    remote function add_student_applicant(Person person) returns PersonData|error? {

        AvinyaType avinya_type_raw = check db_client->queryRow(
        `SELECT *
        FROM avinya_type
        WHERE global_type = "applicant" AND  foundation_type = "student";`
    );

        Person|error? applicantRaw = db_client->queryRow(
        `SELECT *
        FROM person
        WHERE (email = ${person.email}  OR
        phone = ${person.phone} OR 
        jwt_sub_id = ${person.jwt_sub_id}) AND 
        avinya_type_id = ${avinya_type_raw.id};`
    );

        Reference referenceRaw = check db_client->queryRow(
        `SELECT *
        FROM reference_number
        WHERE branch_code = ${person.branch_code} AND foundation_type = 'Student';`
    );

        if (applicantRaw is Person) {
            return error("Applicant already exists. The phone, email, or the social login account you are using is already used by another applicant");
        }

        //     time:Utc currentTime = time:utcNow();

        // string date = time:utcToString(currentTime);

        //     string[] timeArray = regex:split(date, "-");
        //     string year = timeArray[0].substring(2);

        // Generate the dynamic number with leading zeros
        int newLastRefNo = referenceRaw.last_reference_no + 1;
        string dynamicNumberString = padStartWithZeros(newLastRefNo.toString(), 3);
        string newBatchNo = padStartWithZeros(referenceRaw.batch_no.toString(), 2);

        string branch_code = person.branch_code.toString();

        string id_no = string `AF-${branch_code}-${referenceRaw.acedemic_year}-ST${newBatchNo}-${dynamicNumberString}`;

        io:println(id_no);

        sql:ExecutionResult|error res = db_client->execute(
        `INSERT INTO person (
            preferred_name,
            full_name,
            date_of_birth,
            sex,
            organization_id,
            phone,
            email,
            avinya_type_id,
            jwt_sub_id,
            jwt_email,
            street_address,
            id_no
        ) VALUES (
            ${person.preferred_name},
            ${person.full_name},
            ${person.date_of_birth},
            ${person.sex},
            ${person.organization_id},
            ${person.phone},
            ${person.email},
            ${person.avinya_type_id},
            ${person.jwt_sub_id},
            ${person.jwt_email}, 
            ${person.street_address},
            ${id_no}
        );`
    );

        // update last_reference_no in reference_number
        sql:ExecutionResult|error? resUpdate = db_client->execute(
            `UPDATE reference_number
            SET last_reference_no = ${newLastRefNo}
            WHERE branch_code = ${person.branch_code} AND foundation_type = 'Student';`
        );

        if (resUpdate is sql:ExecutionResult) {

            int? insert_count = resUpdate.affectedRowCount;
            if !(insert_count is int) {
                return error("Unable to update Reference Number");
            }
        }
        else {
            return error("Error while updating data", resUpdate);
        }

        if (res is sql:ExecutionResult) {

            int|string? insert_id = res.lastInsertId;
            if (!(insert_id is int)) {
                return error("Unable to insert application");
            }

            return new ((), insert_id);
        }

        io:println(res.toString());

        return error("Error while inserting data", res);

    }

    remote function add_student_applicant_consent(ApplicantConsent applicantConsent) returns ApplicantConsentData|error? {

        ApplicantConsent|error? applicantConsentRaw = db_client->queryRow(
            `SELECT *
            FROM applicant_consent
            WHERE (email = ${applicantConsent.email}  OR
            phone = ${applicantConsent.phone}) AND 
            active = TRUE;`
        );

        if (applicantConsentRaw is ApplicantConsent) {
            return error("Applicant already exists. The phone or the email you provided is already used by another applicant");
        }

        sql:ExecutionResult res = check db_client->execute(
            `INSERT INTO applicant_consent (
                organization_id,
                avinya_type_id,
                person_id,
                application_id,
                name,
                date_of_birth,
                done_ol,
                ol_year,
                done_al,
                al_year,
                al_stream,
                distance_to_school,
                phone,
                email,
                information_correct_consent,
                agree_terms_consent
            ) VALUES (
                ${applicantConsent.organization_id},
                ${applicantConsent.avinya_type_id},
                ${applicantConsent.person_id},
                ${applicantConsent.application_id},
                ${applicantConsent.name},
                ${applicantConsent.date_of_birth},
                ${applicantConsent.done_ol},
                ${applicantConsent.ol_year},
                ${applicantConsent.done_al},
                ${applicantConsent.al_year},
                ${applicantConsent.al_stream},
                ${applicantConsent.distance_to_school},
                ${applicantConsent.phone},
                ${applicantConsent.email},
                ${applicantConsent.information_correct_consent},
                ${applicantConsent.agree_terms_consent}
            );`
        );

        int|string? insert_id = res.lastInsertId;
        if !(insert_id is int) {
            return error("Unable to insert person");
        }

        return new ((), applicantConsent.phone);
    }

    remote function add_application(Application application) returns ApplicationData|error? {
        sql:ExecutionResult res = check db_client->execute(
            `INSERT INTO application (
                person_id,
                vacancy_id
            ) VALUES (
                ${application.person_id},
                ${application.vacancy_id}
            );`
        );

        int|string? insert_id = res.lastInsertId;
        if !(insert_id is int) {
            return error("Unable to insert application");
        }

        res = check db_client->execute(
            `INSERT INTO application_status (
                application_id
            ) VALUES (
                ${insert_id}
            );`
        ); // default status with for new application is "New" and is_terminal false

        return new (insert_id);
    }

    resource function get all_evaluations() returns EvaluationData[]|error {
        stream<Evaluation, error?> evaluations;
        lock {
            evaluations = db_client->query(
                `SELECT *
                FROM evaluation 
                ORDER BY id DESC
                `
            );
        }

        EvaluationData[] evaluationsDatas = [];

        check from Evaluation evaluation in evaluations
            do {
                EvaluationData|error evaluationData = new EvaluationData(0, evaluation);
                if !(evaluationData is error) {
                    evaluationsDatas.push(evaluationData);
                }
            };

        check evaluations.close();
        return evaluationsDatas;
    }

    remote function add_evaluations(Evaluation[] evaluations) returns int|error? {

        int count = 0;

        foreach Evaluation evaluation in evaluations {
            sql:ExecutionResult res = check db_client->execute(
                `INSERT INTO evaluation (
                    evaluatee_id,
                    evaluator_id,
                    evaluation_criteria_id,
                    activity_instance_id,
                    response,
                    notes,
                    grade
                ) VALUES (
                    ${evaluation.evaluatee_id},
                    ${evaluation.evaluator_id},
                    ${evaluation.evaluation_criteria_id},
                    ${evaluation.activity_instance_id},
                    ${evaluation.response},
                    ${evaluation.notes},
                    ${evaluation.grade}
                );`
            );

            int|string? insert_id = res.lastInsertId;
            if !(insert_id is int) {
                return error("Unable to insert evaluations");
            } else {
                count += 1;
            }

            // Insert child and parent evaluation relationships
            int[] child_eval_ids = evaluation.child_evaluations ?: [];
            int[] parent_eval_ids = evaluation.parent_evaluations ?: [];

            foreach int child_idx in child_eval_ids {
                _ = check db_client->execute(
                    `INSERT INTO parent_child_evaluation (
                        child_evaluation_id,
                        parent_evaluation_id
                    ) VALUES (
                        ${child_idx}, ${insert_id}
                    );`
                );
            }

            foreach int parent_idx in parent_eval_ids {
                _ = check db_client->execute(
                    `INSERT INTO parent_child_evaluation (
                        child_evaluation_id,
                        parent_evaluation_id
                    ) VALUES (
                        ${insert_id}, ${parent_idx}
                    );`
                );
            }
        }

        return count;
    }

    remote function update_evaluation(Evaluation evaluation) returns EvaluationData|error? {
        int id = evaluation.id ?: 0;
        if (id == 0) {
            return error("Unable to update evaluation");
        }

        sql:ExecutionResult res = check db_client->execute(
            `UPDATE evaluation SET
                    evaluatee_id = ${evaluation.evaluatee_id},
                    evaluator_id = ${evaluation.evaluator_id},
                    evaluation_criteria_id = ${evaluation.evaluation_criteria_id},
                    activity_instance_id = ${evaluation.activity_instance_id},
                    response = ${evaluation.response},
                    notes = ${evaluation.notes},
                    grade = ${evaluation.grade}
            WHERE id = ${id};`
        );

        if (res.affectedRowCount == sql:EXECUTION_FAILED) {
            return error("unable to update evaluations");
        }
        return new (id);
    }

    remote function delete_evaluation(int id) returns int?|error? {
        sql:ExecutionResult res = check db_client->execute(
            `DELETE FROM evaluation WHERE id = ${id};`
        );

        int? delete_id = res.affectedRowCount;
        if (delete_id <= 0) {
            return error("Unable to delete evaluation with id: " + id.toString());
        }

        return delete_id;
    }

    isolated resource function get activity_evaluations(int activity_id) returns EvaluationData[]|error? {
        stream<Evaluation, error?> activityEvaluations;
        lock {
            activityEvaluations = db_client->query(
                `SELECT e.*
                FROM
                    evaluation e
                        JOIN
                    activity_instance ai ON e.activity_instance_id = ai.id
                        JOIN
                    activity a ON ai.activity_id = a.id
                WHERE
                    activity_id = ${activity_id};`
            );
        }

        EvaluationData[] activityEvaluationsData = [];

        check from Evaluation evaluation in activityEvaluations
            do {
                EvaluationData|error evaluationData = new EvaluationData((), evaluation);
                if !(evaluationData is error) {
                    activityEvaluationsData.push(evaluationData);
                }
            };

        check activityEvaluations.close();
        return activityEvaluationsData;

    }

    isolated resource function get activity_instance_evaluations(int activity_instance_id) returns EvaluationData[]|error? {
        stream<Evaluation, error?> activityInstanceEvaluations;
        lock {
            activityInstanceEvaluations = db_client->query(
                `SELECT *
                FROM evaluation
                WHERE activity_instance_id = ${activity_instance_id};`
            );
        }

        EvaluationData[] activityInstanceEvaluationsData = [];

        check from Evaluation pctiEvaluation in activityInstanceEvaluations
            do {
                EvaluationData|error pctiEvaluationData = new EvaluationData((), pctiEvaluation);
                if !(pctiEvaluationData is error) {
                    activityInstanceEvaluationsData.push(pctiEvaluationData);
                }
            };

        check activityInstanceEvaluations.close();
        return activityInstanceEvaluationsData;

    }

    isolated resource function get evaluation_meta_data(int meta_evaluation_id) returns EvaluationMetadataData|error? {

        return new (meta_evaluation_id);

    }

    remote function add_evaluation_meta_data(EvaluationMetadata metadata) returns EvaluationMetadataData|error? {

        EvaluationMetadata|error? metaDataRaw = db_client->queryRow(
            `SELECT *
            FROM evaluation_metadata
            WHERE evaluation_id = ${metadata.evaluation_id};`
        );

        if (metaDataRaw is EvaluationMetadata) {
            return error("Evaluation id already exists");
        }

        sql:ExecutionResult res = check db_client->execute(
            `INSERT INTO evaluation_metadata(                
                evaluation_id,
				location,
				level,
				meta_type,
                status,
				focus,
				metadata
            ) VALUES(                
				${metadata.evaluation_id},
				${metadata.location},
				${metadata.level},
				${metadata.meta_type},
                ${metadata.status},
				${metadata.focus},	
				${metadata.metadata}
			);`
        );

        int|string? insert_id = res.lastInsertId;
        if !(insert_id is int) {
            return error("Unable to insert meta data");
        }
        return new (insert_id);

    }

    isolated resource function get evaluationCriteria(string? prompt, int? id) returns EvaluationCriteriaData|error {
        return new (prompt, id);
    }

    remote function add_evaluation_criteria(EvaluationCriteria evaluationCriteria) returns EvaluationCriteriaData|error? {
        EvaluationCriteria|error? criteriaRaw = db_client->queryRow(
            `SELECT *
            FROM evaluation_criteria
            WHERE (prompt = ${evaluationCriteria.prompt} AND
            id = ${evaluationCriteria.id});`
        );
        if (criteriaRaw is EvaluationCriteria) {
            return error("Evaluation criteria already exists. The prompt and is  you are using is already used by another criteria");
        }

        sql:ExecutionResult res = check db_client->execute(
            `INSERT INTO  evaluation_criteria(
                prompt,
                description,
                expected_answer,
                rating_out_of
                ) VALUES(
                    ${evaluationCriteria.prompt},
                    ${evaluationCriteria.description},
                    ${evaluationCriteria.expected_answer},
                    ${evaluationCriteria.rating_out_of}
                    );`
        );

        int|string? insert_id = res.lastInsertId;
        if !(insert_id is int) {
            return error("Unable to insert evaluation criteria");
        }

        return new (evaluationCriteria.prompt);

    }

    remote function add_evaluation_answer_option(EvaluationCriteriaAnswerOption evaluationAnswer) returns EvaluationCriteriaAnswerOptionData|error? {

        sql:ExecutionResult res = check db_client->execute(
            `INSERT INTO evaluation_criteria_answer_option(
                evaluation_criteria_id,
                answer,
                expected_answer
                ) VALUES(
                    ${evaluationAnswer.evaluation_criteria_id},
                    ${evaluationAnswer.answer},
                    ${evaluationAnswer.expected_answer}
                );`
        );

        int|string? insert_id = res.lastInsertId;
        if !(insert_id is int) {
            return error("Unable to insert evalution criteria answer");
        }
        return new (evaluationAnswer.answer);
    }

    remote function add_evaluation_cycle(EvaluationCycle evaluationCycle) returns int|error? {
        sql:ExecutionResult res = check db_client->execute(
            `INSERT INTO  evaluation_cycle(
                name,
                description,
                start_date,
                end_date
            ) VALUES (
                ${evaluationCycle.name},
                ${evaluationCycle.description},
                ${evaluationCycle.start_date},
                ${evaluationCycle.end_date}
            );`
        );

        int|string? lastInsertId = res.lastInsertId;
        if (lastInsertId is int) {
            return lastInsertId;
        } else {
            return error("unable to obtain last insert Id for evaluaton Cycle");
        }
    }

    # Description
    #
    # + id - Parameter Description  
    # + name - Parameter Description
    # + return - Return Value Description
    isolated resource function get evaluation_cycle(string? name, int? id) returns EvaluationCycleData|error {
        return new (name, id);
    }

    remote function update_evaluation_cycles(EvaluationCycle evaluation_cycle) returns int|error {
        sql:ExecutionResult res = check db_client->execute(
            `UPDATE evaluation_cycle SET
                name = ${evaluation_cycle.name},
                description =  ${evaluation_cycle.description},
                start_date = ${evaluation_cycle.start_date},
                end_date = ${evaluation_cycle.end_date}
          WHERE  id = ${evaluation_cycle.id}`
        );
        int|string? affectedRows = res.affectedRowCount;
        if (affectedRows is int) {
            return affectedRows;
        } else {
            return error("Unable to obtian last affected count for evaluation cycle");
        }
    }

    remote function add_education_experience(EducationExperience education_experience) returns EducationExperienceData|error? {

        EducationExperience|error? education_experience_raw = db_client->queryRow(
            `SELECT *
            FROM education_experience
            WHERE person_id = ${education_experience.person_id};`
            );

        if (education_experience_raw is EducationExperience) {
            return error("Person is already exists. The person id already exists");
        }

        sql:ExecutionResult res = check db_client->execute(
            `INSERT INTO education_experience(
                    person_id,
                    school,
                    start_date,
                    end_date
            ) VALUES(
                ${education_experience.person_id},
                ${education_experience.school},
                ${education_experience.start_date},
                ${education_experience.end_date}
            );`
        );

        int|string? insert_id = res.lastInsertId;
        if !(insert_id is int) {
            return error("Unable to insert education_experience");
        }

        int[] education_eval_ids = education_experience.evaluation_id ?: [];

        foreach int eval_idx in education_eval_ids {
            _ = check db_client->execute(
                            `INSERT INTO education_experience_evaluation(
                                education_experience_id,
                                evaluation_id
                            ) VALUES(
                                ${insert_id},
                                ${eval_idx}
                            );`
                        );
        }

        return new (insert_id);

    }

    isolated resource function get education_experience(int? id) returns EducationExperienceData|error? {
        return new (id);
    }

    isolated resource function get education_experience_byPerson(int? person_id) returns EducationExperienceData[]|error {
        stream<EducationExperience, error?> education_experiences;
        lock {
            education_experiences = db_client->query(
                `SELECT * 
                FROM education_experience
                WHERE person_id=${person_id}
                `
            );
        }

        EducationExperienceData[] educationExperienceDatas = [];

        check from EducationExperience education_experience in education_experiences
            do {
                EducationExperienceData|error educationExperienceData = new EducationExperienceData(0, 0, education_experience);
                if !(educationExperienceData is error) {
                    educationExperienceDatas.push(educationExperienceData);
                }
            };
        check education_experiences.close();
        return educationExperienceDatas;
    }

    remote function add_work_experience(WorkExperience work_experience) returns WorkExperienceData|error? {

        WorkExperience|error? work_experience_raw = db_client->queryRow(
            `SELECT *
            FROM work_experience
            WHERE person_id = ${work_experience.person_id};`
            );

        if (work_experience_raw is WorkExperience) {
            return error("Person is already exists.");
        }

        sql:ExecutionResult res = check db_client->execute(
            `INSERT INTO work_experience(
                    person_id,
                    organization,
                    start_date,
                    end_date
            ) VALUES(
                ${work_experience.person_id},
                ${work_experience.organization},
                ${work_experience.start_date},
                ${work_experience.end_date}
            );`
        );

        int|string? insert_id = res.lastInsertId;
        if !(insert_id is int) {
            return error("Unable to insert work_experience");
        }
        int[] work_eval_ids = work_experience.evaluation_id ?: [];

        foreach int eval_idx in work_eval_ids {
            _ = check db_client->execute(
                            `INSERT INTO work_experience_evaluation(
                                work_experience_id,
                                evaluation_id
                            ) VALUES(
                                ${insert_id},
                                ${eval_idx}
                            );`
                        );
        }

        return new (insert_id);

    }

    isolated resource function get work_experience(int? id) returns WorkExperienceData|error? {
        return new (id);
    }

    isolated resource function get work_experience_ByPerson(int? person_id) returns WorkExperienceData[]|error? {
        stream<WorkExperience, error?> work_experiences;
        lock {
            work_experiences = db_client->query(
                `SELECT * 
                FROM work_experience
                WHERE person_id = ${person_id}`
            );
        }

        WorkExperienceData[] workExperienceDatas = [];

        check from WorkExperience work_experience in work_experiences
            do {
                WorkExperienceData|error workExperienceData = new WorkExperienceData(0, 0, work_experience);
                if !(workExperienceData is error) {
                    workExperienceDatas.push(workExperienceData);
                }
            };
        check work_experiences.close();
        return workExperienceDatas;
    }

    remote function add_address(Address address) returns AddressData|error? {
        sql:ExecutionResult res = check db_client->execute(
            `INSERT INTO address (
                street_address,
                phone,
                city_id
            ) VALUES (
                ${address.street_address},
                ${address.phone},
                ${address.city_id}
            );`
        );

        int|string? insert_id = res.lastInsertId;
        if !(insert_id is int) {
            return error("Unable to insert addresss");
        }

        return new (insert_id);
    }

    remote function add_prospect(Prospect prospect) returns ProspectData|error? {
        Prospect|error? prospectRaw = db_client->queryRow(
            `SELECT *
            FROM prospect
            WHERE (email = ${prospect.email}  OR
            phone = ${prospect.phone}) AND 
            active = TRUE;`
        );

        if (prospectRaw is Prospect) {
            return error("Prospect already exists. The phone or the email you provided is already used by another prospect");
        }

        sql:ExecutionResult res = check db_client->execute(
            `INSERT INTO prospect (
                name,
                phone,
                email,
                receive_information_consent,
                agree_terms_consent,
                street_address,
                date_of_birth,
                done_ol,
                ol_year,
                distance_to_school
            ) VALUES (
                ${prospect.name},
                ${prospect.phone},
                ${prospect.email},
                ${prospect.receive_information_consent},
                ${prospect.agree_terms_consent},
                ${prospect.street_address},
                ${prospect.date_of_birth},
                ${prospect.done_ol},
                ${prospect.ol_year},
                ${prospect.distance_to_school}
            );`
        );

        int|string? insert_id = res.lastInsertId;
        if !(insert_id is int) {
            return error("Unable to insert addresss");
        }

        return new (prospect.email, prospect.phone);
    }

    remote function add_organization(Organization org) returns OrganizationData|error? {
        sql:ExecutionResult res = check db_client->execute(
            `INSERT INTO organization (
                name_en,
                name_si,
                name_ta,
                address_id,
                phone,
                avinya_type,
                description,
                notes
            ) VALUES (
                ${org.name_en},
                ${org.name_si},
                ${org.name_ta},
                ${org.address_id},
                ${org.phone},
                ${org.avinya_type},
                ${org.description},
                ${org.notes}
            );`
        );

        int|string? insert_id = res.lastInsertId;
        if !(insert_id is int) {
            return error("Unable to insert organization");
        }

        // Insert child and parent organization relationships
        int[] child_eval_ids = org.child_organizations ?: [];
        int[] parent_eval_ids = org.parent_organizations ?: [];

        foreach int child_idx in child_eval_ids {
            _ = check db_client->execute(
                `INSERT INTO parent_child_organization (
                    child_org_id,
                    parent_org_id
                ) VALUES (
                    ${child_idx}, ${insert_id}
                );`
            );
        }

        foreach int parent_idx in parent_eval_ids {
            _ = check db_client->execute(
                `INSERT INTO parent_child_organization (
                    child_org_id,
                    parent_org_id
                ) VALUES (
                    ${insert_id}, ${parent_idx}
                );`
            );
        }

        return new ((), insert_id);
    }

    // Activity entry point is the activity name. e.g "School Day"
    // then we can get the list of activity instances related to that activity 
    isolated resource function get activity(string? name, int? id = 0) returns ActivityData|error? {
        return new (name, id);
    }

    remote function add_attendance(ActivityParticipantAttendance attendance) returns ActivityParticipantAttendanceData|error? {
        // only today's attendance can be added with this method 
        ActivityParticipantAttendance|error todayActivityParticipantAttendance = db_client->queryRow(
            `SELECT *
            FROM activity_participant_attendance
            WHERE person_id = ${attendance.person_id} and 
            activity_instance_id = ${attendance.activity_instance_id} and
            DATE(sign_in_time) = CURDATE();`
        );
        if (todayActivityParticipantAttendance is ActivityParticipantAttendance) {
            if (attendance.sign_in_time != null) {

                return new (todayActivityParticipantAttendance.id);
            }
            else if (attendance.sign_out_time != null) {
                todayActivityParticipantAttendance = db_client->queryRow(
                    `SELECT *
                    FROM activity_participant_attendance
                    WHERE person_id = ${attendance.person_id} and 
                    activity_instance_id = ${attendance.activity_instance_id} and
                    DATE(sign_out_time) = CURDATE();`
                );
                if (todayActivityParticipantAttendance is ActivityParticipantAttendance) {
                    return new (todayActivityParticipantAttendance.id);
                }
            }
        }
        sql:ExecutionResult res = check db_client->execute(
            `INSERT INTO activity_participant_attendance (
                activity_instance_id,
                person_id,
                sign_in_time,
                sign_out_time,
                in_marked_by,
                out_marked_by
            ) VALUES (
                ${attendance.activity_instance_id},
                ${attendance.person_id},
                ${attendance.sign_in_time},
                ${attendance.sign_out_time},
                ${attendance.in_marked_by},
                ${attendance.out_marked_by}
            );`
        );

        int|string? insert_id = res.lastInsertId;
        if !(insert_id is int) {
            return error("Unable to insert attendance");
        }

        return new (insert_id);
    }

    remote function delete_attendance(int id) returns int?|error? {
        sql:ExecutionResult res = check db_client->execute(
            `DELETE FROM activity_participant_attendance WHERE id = ${id};`
        );

        int? delete_id = res.affectedRowCount;
        if (delete_id <= 0) {
            return error("Unable to delete attendance instance with id: " + id.toString());
        }

        return delete_id;
    }

    remote function delete_person_attendance(int person_id) returns int?|error? {
        sql:ExecutionResult res = check db_client->execute(
            `DELETE FROM activity_participant_attendance WHERE person_id = ${person_id} AND
            DATE(created) = CURDATE();`
        );

        int? delete_count = res.affectedRowCount;
        if (delete_count <= 0) {
            return error("Unable to delete attendance instance with id: " + person_id.toString());
        }

        return delete_count;
    }

    isolated resource function get class_attendance_today(int? organization_id, int? activity_id) returns ActivityParticipantAttendanceData[]|error? {
        stream<ActivityParticipantAttendance, error?> attendance_records;

        lock {
            attendance_records = db_client->query(
                `SELECT * 
                FROM activity_participant_attendance
                WHERE person_id in (SELECT id FROM person WHERE organization_id = ${organization_id}) AND 
                activity_instance_id in (SELECT id FROM activity_instance WHERE activity_id = ${activity_id} AND start_time >= CURDATE() AND end_time <= CURDATE() + INTERVAL 1 DAY);`
            );
        }

        ActivityParticipantAttendanceData[] attendnaceDatas = [];

        check from ActivityParticipantAttendance attendance_record in attendance_records
            do {
                ActivityParticipantAttendanceData|error activityParticipantAttendanceData = new ActivityParticipantAttendanceData(0, attendance_record);
                if !(activityParticipantAttendanceData is error) {
                    attendnaceDatas.push(activityParticipantAttendanceData);
                }
            };
        check attendance_records.close();
        return attendnaceDatas;
    }

    isolated resource function get person_attendance_today(int? person_id, int? activity_id) returns ActivityParticipantAttendanceData[]|error? {
        stream<ActivityParticipantAttendance, error?> attendance_records;

        lock {
            attendance_records = db_client->query(
                `SELECT * 
                FROM activity_participant_attendance
                WHERE person_id = ${person_id} AND 
                activity_instance_id in (SELECT id FROM activity_instance WHERE activity_id = ${activity_id} AND 
                start_time >= CURDATE() AND end_time <= CURDATE() + INTERVAL 1 DAY);`
            );
        }

        ActivityParticipantAttendanceData[] attendnaceDatas = [];

        check from ActivityParticipantAttendance attendance_record in attendance_records
            do {
                ActivityParticipantAttendanceData|error activityParticipantAttendanceData = new ActivityParticipantAttendanceData(0, attendance_record);
                if !(activityParticipantAttendanceData is error) {
                    attendnaceDatas.push(activityParticipantAttendanceData);
                }
            };
        check attendance_records.close();
        return attendnaceDatas;
    }

    isolated resource function get person_attendance_report(int? person_id, int? activity_id, int? result_limit = 0) returns ActivityParticipantAttendanceData[]|error? {
        stream<ActivityParticipantAttendance, error?> attendance_records;

        if (result_limit > 0) {
            lock {
                attendance_records = db_client->query(
                    `SELECT * 
                    FROM activity_participant_attendance
                    WHERE person_id = ${person_id} AND 
                    activity_instance_id in (SELECT id FROM activity_instance WHERE activity_id = ${activity_id}) 
                    ORDER BY sign_in_time DESC
                    LIMIT ${result_limit};`
                );
            }
        } else {
            lock {
                attendance_records = db_client->query(
                    `SELECT * 
                    FROM activity_participant_attendance
                    WHERE person_id = ${person_id} AND 
                    activity_instance_id in (SELECT id FROM activity_instance WHERE activity_id = ${activity_id})
                    ORDER BY sign_in_time DESC;`
                );
            }
        }

        ActivityParticipantAttendanceData[] attendnaceDatas = [];

        check from ActivityParticipantAttendance attendance_record in attendance_records
            do {
                ActivityParticipantAttendanceData|error activityParticipantAttendanceData = new ActivityParticipantAttendanceData(0, attendance_record);
                if !(activityParticipantAttendanceData is error) {
                    attendnaceDatas.push(activityParticipantAttendanceData);
                }
            };
        check attendance_records.close();
        return attendnaceDatas;
    }

    isolated resource function get class_attendance_report(int? organization_id, int? parent_organization_id, int? activity_id, int? result_limit = 0, string? from_date = "", string? to_date = "") returns ActivityParticipantAttendanceData[]|error? {
        stream<ActivityParticipantAttendance, error?> attendance_records;

        time:Utc startTime = time:utcNow();

        if (result_limit > 0) {
            lock {
                int|error? avinya_type_id = db_client->queryRow(
            `SELECT p.avinya_type_id FROM organization o left join person p on o.id = p.organization_id WHERE o.id = ${organization_id} AND p.avinya_type_id NOT IN (99, 100) ORDER BY p.avinya_type_id LIMIT 1;`
        );
                io:println("Eval Criteria ID: ", (check avinya_type_id).toString());

                if !(avinya_type_id is int) {
                    io:println("Eval Criteria ID: ", (check avinya_type_id).toString());
                    return error("AvinyaType ID does not exist");
                }
                attendance_records = db_client->query(
                    `SELECT * 
                    FROM activity_participant_attendance
                    WHERE person_id in (SELECT id FROM person WHERE organization_id = ${organization_id} AND avinya_type_id=${avinya_type_id}) AND 
                    activity_instance_id in (SELECT id FROM activity_instance WHERE activity_id = ${activity_id}) 
                    ORDER BY created DESC
                    LIMIT ${result_limit};`
                );
            }
        } else {
            if (from_date != null && to_date != null) {
                if (organization_id != null) {
                    lock {
                        int|error? avinya_type_id = db_client->queryRow(
            `SELECT p.avinya_type_id FROM organization o left join person p on o.id = p.organization_id WHERE o.id = ${organization_id} AND p.avinya_type_id NOT IN (99, 100) ORDER BY p.avinya_type_id LIMIT 1;`
        );
                        io:println("Eval Criteria ID: ", (check avinya_type_id).toString());

                        if !(avinya_type_id is int) {
                            io:println("Eval Criteria ID: ", (check avinya_type_id).toString());
                            return error("AvinyaType ID does not exist");
                        }
                        attendance_records = db_client->query(
                        `SELECT *
                        FROM activity_participant_attendance
                        WHERE person_id IN (SELECT id FROM person WHERE organization_id = ${organization_id} AND avinya_type_id=${avinya_type_id})
                        AND activity_instance_id IN (SELECT id FROM activity_instance WHERE activity_id = ${activity_id})
                        AND DATE(sign_in_time) BETWEEN ${from_date} AND ${to_date}
                        ORDER BY created DESC;`
                    );
                    }
                } else {
                    lock {
                        attendance_records = db_client->query(
                            `SELECT *
                            FROM activity_participant_attendance
                            WHERE person_id in (SELECT id FROM person WHERE avinya_type_id IN (37, 10, 96) AND
                            organization_id in (SELECT id FROM organization WHERE id in (SELECT child_org_id FROM parent_child_organization WHERE parent_org_id IN (SELECT child_org_id from parent_child_organization where parent_org_id = ${parent_organization_id})) AND avinya_type IN (87, 10, 96)))
                            AND activity_instance_id in (SELECT id FROM activity_instance WHERE activity_id = ${activity_id}) 
                            AND DATE(sign_in_time) BETWEEN ${from_date} AND ${to_date}
                            ORDER BY DATE(sign_in_time),created DESC;`
                        );
                    }
                }
            } else {
                lock {
                    int|error? avinya_type_id = db_client->queryRow(
            `SELECT p.avinya_type_id FROM organization o left join person p on o.id = p.organization_id WHERE o.id = ${organization_id} AND p.avinya_type_id NOT IN (99, 100) ORDER BY p.avinya_type_id LIMIT 1;`
        );
                    io:println("Eval Criteria ID: ", (check avinya_type_id).toString());

                    if !(avinya_type_id is int) {
                        io:println("Eval Criteria ID: ", (check avinya_type_id).toString());
                        return error("AvinyaType ID does not exist");
                    }
                    attendance_records = db_client->query(
                        `SELECT * 
                        FROM activity_participant_attendance
                        WHERE person_id in (SELECT id FROM person WHERE organization_id = ${organization_id} AND avinya_type_id=${avinya_type_id}) AND 
                        activity_instance_id in (SELECT id FROM activity_instance WHERE activity_id = ${activity_id}) 
                        ORDER BY created DESC;`
                    );
                }
            }
        }

        time:Utc endTime = time:utcNow();
        time:Seconds seconds = time:utcDiffSeconds(endTime, startTime);

        log:printInfo("Time taken to query execution in class_attendance_report in seconds = " + seconds.toString());

        ActivityParticipantAttendanceData[] attendnaceDatas = [];

        check from ActivityParticipantAttendance attendance_record in attendance_records
            do {
                ActivityParticipantAttendanceData|error activityParticipantAttendanceData = new ActivityParticipantAttendanceData(0, attendance_record);
                if !(activityParticipantAttendanceData is error) {
                    attendnaceDatas.push(activityParticipantAttendanceData);
                } else {
                    log:printInfo("Error in class_attendance_report = " + activityParticipantAttendanceData.toString());
                }
            };
        check attendance_records.close();
        return attendnaceDatas;
    }

    isolated resource function get late_attendance_report(int? organization_id, int? parent_organization_id, int? activity_id, int? result_limit = 0, string? from_date = "", string? to_date = "") returns ActivityParticipantAttendanceDataForLateAttendance[]|error? {
        stream<ActivityParticipantAttendanceForLateAttendance, error?> attendance_records;

        time:Utc startTime = time:utcNow();

        if (result_limit > 0) {
            int|error? avinya_type_id = db_client->queryRow(
                    `SELECT p.avinya_type_id FROM organization o left join person p on o.id = p.organization_id WHERE o.id = ${organization_id} AND p.avinya_type_id NOT IN (99, 100) ORDER BY p.avinya_type_id LIMIT 1;`
                );
            io:println("Eval Criteria ID: ", (check avinya_type_id).toString());

            if !(avinya_type_id is int) {
                io:println("Eval Criteria ID: ", (check avinya_type_id).toString());
                return error("AvinyaType ID does not exist");
            }
            lock {
                attendance_records = db_client->query(
                    `SELECT apa.*,p.preferred_name,p.digital_id
FROM activity_participant_attendance apa
LEFT JOIN person p ON apa.person_id = p.id
                    FROM activity_participant_attendance
                    WHERE person_id in (SELECT id FROM person WHERE organization_id = ${organization_id} AND avinya_type_id=${avinya_type_id}) AND 
                    activity_instance_id in (SELECT id FROM activity_instance WHERE activity_id = ${activity_id}) 
                    AND TIME_FORMAT(sign_in_time, '%H:%i:%s') > '08:30:59'
                    ORDER BY created DESC
                    LIMIT ${result_limit};`
                );
            }
        } else {
            if (from_date != null && to_date != null) {
                if (organization_id != null) {

                    int|error? avinya_type_id = db_client->queryRow(
                            `SELECT p.avinya_type_id FROM organization o left join person p on o.id = p.organization_id WHERE o.id = ${organization_id} AND p.avinya_type_id NOT IN (99, 100) ORDER BY p.avinya_type_id LIMIT 1;`
                        );
                    io:println("Eval Criteria ID: ", (check avinya_type_id).toString());

                    if !(avinya_type_id is int) {
                        io:println("Eval Criteria ID: ", (check avinya_type_id).toString());
                        return error("AvinyaType ID does not exist");
                    }

                    lock {
                        attendance_records = db_client->query(
                        `SELECT apa.*,p.preferred_name,p.digital_id
FROM activity_participant_attendance apa
LEFT JOIN person p ON apa.person_id = p.id
                        WHERE person_id IN (SELECT id FROM person WHERE organization_id = ${organization_id} AND avinya_type_id=${avinya_type_id})
                        AND activity_instance_id IN (SELECT id FROM activity_instance WHERE activity_id = ${activity_id})
                        AND DATE(sign_in_time) BETWEEN ${from_date} AND ${to_date}
                        AND TIME_FORMAT(sign_in_time, '%H:%i:%s') > '08:30:59'
                        ORDER BY created DESC;`
                    );
                    }
                } else {
                    lock {
                        attendance_records = db_client->query(
                            `SELECT apa.*,o.description,p.preferred_name,p.digital_id
                                FROM activity_participant_attendance apa
                                LEFT JOIN person p ON apa.person_id = p.id
                                LEFT JOIN organization o ON p.organization_id = o.id
                                WHERE apa.person_id in (SELECT id FROM person WHERE avinya_type_id IN (37, 10, 96) AND
                                organization_id in (SELECT id FROM organization WHERE id in (SELECT child_org_id FROM parent_child_organization WHERE parent_org_id IN (SELECT child_org_id from parent_child_organization where parent_org_id = ${parent_organization_id})) AND avinya_type IN (87, 10, 96)))
                                AND apa.activity_instance_id in (SELECT id FROM activity_instance WHERE activity_id = ${activity_id}) 
                                AND DATE(apa.sign_in_time) BETWEEN ${from_date} AND ${to_date}
                                AND TIME_FORMAT(apa.sign_in_time, '%H:%i:%s') > '08:30:59'
                                ORDER BY DATE(apa.sign_in_time) DESC;`
                        );
                    }
                }
            } else {
                int|error? avinya_type_id = db_client->queryRow(
                            `SELECT p.avinya_type_id FROM organization o left join person p on o.id = p.organization_id WHERE o.id = ${organization_id} AND p.avinya_type_id NOT IN (99, 100) ORDER BY p.avinya_type_id LIMIT 1;`
                        );
                io:println("Eval Criteria ID: ", (check avinya_type_id).toString());

                if !(avinya_type_id is int) {
                    io:println("Eval Criteria ID: ", (check avinya_type_id).toString());
                    return error("AvinyaType ID does not exist");
                }

                lock {
                    attendance_records = db_client->query(
                        `SELECT apa.*,p.preferred_name,p.digital_id
                        FROM activity_participant_attendance apa
                        LEFT JOIN person p ON apa.person_id = p.id
                        WHERE person_id in (SELECT id FROM person WHERE organization_id = ${organization_id} AND avinya_type_id=${avinya_type_id}) AND 
                        activity_instance_id in (SELECT id FROM activity_instance WHERE activity_id = ${activity_id}) 
                        AND TIME_FORMAT(sign_in_time, '%H:%i:%s') > '08:30:59'
                        ORDER BY created DESC;`
                    );
                }
            }
        }

        time:Utc endTime = time:utcNow();
        time:Seconds seconds = time:utcDiffSeconds(endTime, startTime);

        log:printInfo("Time taken to query execution in late_attendance_report in seconds = " + seconds.toString());

        ActivityParticipantAttendanceDataForLateAttendance[] attendnaceDatas = [];

        check from ActivityParticipantAttendanceForLateAttendance attendance_record in attendance_records
            do {
                ActivityParticipantAttendanceDataForLateAttendance|error activityParticipantAttendanceData = new ActivityParticipantAttendanceDataForLateAttendance(0, attendance_record);
                if !(activityParticipantAttendanceData is error) {
                    attendnaceDatas.push(activityParticipantAttendanceData);
                }
            };
        check attendance_records.close();
        return attendnaceDatas;
    }

    remote function add_empower_parent(Person person) returns PersonData|error? {

        AvinyaType avinya_type_raw = check db_client->queryRow(
            `SELECT *
            FROM avinya_type
            WHERE global_type = "customer" AND  foundation_type = "parent";`
        );

        Person|error? applicantRaw = db_client->queryRow(
            `SELECT *
            FROM person
            WHERE (email = ${person.email}  OR
            phone = ${person.phone} OR
            jwt_sub_id = ${person.jwt_sub_id}) AND 
            avinya_type_id = ${avinya_type_raw.id};`
        );

        if (applicantRaw is Person) {
            return error("Parent already exists. The phone, email or the social login account you are using is already used by another parent");
        }

        sql:ExecutionResult res = check db_client->execute(
            `INSERT INTO person (
                preferred_name,
                full_name,
                sex,
                organization_id,
                phone,
                email,
                avinya_type_id,
                permanent_address_id,
                mailing_address_id,
                jwt_sub_id,
                jwt_email
            ) VALUES (
                ${person.preferred_name},
                ${person.full_name},
                ${person.sex},
                ${person.organization_id},
                ${person.phone},
                ${person.email},
                ${avinya_type_raw.id},
                ${person.permanent_address_id},
                ${person.mailing_address_id},
                ${person.jwt_sub_id},
                ${person.jwt_email}
            );`
        );

        int|string? insert_id = res.lastInsertId;
        if !(insert_id is int) {
            return error("Unable to insert parent");
        }

        // Insert child and parent student relationships
        int[] child_student_ids = person.child_student ?: [];
        int[] parent_student_ids = person.parent_student ?: [];

        foreach int child_idx in child_student_ids {
            _ = check db_client->execute(
                `INSERT INTO parent_child_student (
                    child_student_id,
                    parent_student_id
                ) VALUES (
                    ${child_idx}, ${insert_id}
                );`
            );
        }

        foreach int parent_idx in parent_student_ids {
            _ = check db_client->execute(
                `INSERT INTO parent_child_student (
                    child_student_id,
                    parent_student_id
                ) VALUES (
                    ${insert_id}, ${parent_idx}
                );`
            );
        }

        return new ((), insert_id);

    }

    remote function update_application_status(string applicationStatus, int applicationId) returns ApplicationStatusData|error? {

        ApplicationStatus|error? appStatusRaw = db_client->queryRow(
            `SELECT *
            FROM application_status
            WHERE(application_id = ${applicationId});`

        );

        if !(appStatusRaw is ApplicationStatus) {
            return error("Application does not exist");
        }

        // add new application_status
        sql:ExecutionResult|error res = db_client->execute(
            `INSERT INTO application_status (
                application_id,
                status
            ) VALUES (
                ${applicationId},
                ${applicationStatus}
            );`
        );

        if (res is sql:ExecutionResult) {

            int? insert_count = res.affectedRowCount;
            if !(insert_count is int) {
                return error("Unable to update application status");
            }

            return new ((), appStatusRaw);
        }

        io:println(res.toString());

        return error("Error while inserting data", res);

    }

    remote function update_person_avinya_type(int personId, int newAvinyaId, string transitionDate) returns PersonData|error? {
        Person|error? personRaw = db_client->queryRow(
            `SELECT *
            FROM person
            WHERE (id = ${personId});`
        );

        if !(personRaw is Person) {
            return error("Person does not exist");
        }

        // add to person_avinya_type_transition_history
        sql:ExecutionResult|error? resAdd = db_client->execute(
            `INSERT INTO person_avinya_type_transition_history(
                    person_id,
                    previous_avinya_type_id,
                    new_avinya_type_id,
                    transition_date
                ) VALUES (
                    ${personId},
                    ${personRaw.avinya_type_id},
                    ${newAvinyaId},
                    ${transitionDate}  
                );`
        );

        // update avinya_type_id in Person
        sql:ExecutionResult|error? resUpdate = db_client->execute(
            `UPDATE person
            SET avinya_type_id = ${newAvinyaId}
            WHERE(id = ${personId});`
        );

        if (resUpdate is sql:ExecutionResult) {

            int? insert_count = resUpdate.affectedRowCount;
            if !(insert_count is int) {
                return error("Unable to update person's avinya type");
            }
        }
        else {
            return error("Error while updating data", resUpdate);
        }

        if (resAdd is sql:ExecutionResult) {

            int|string? insert_id = resAdd.lastInsertId;
            if !(insert_id is int) {
                return error("Unable to insert person_avinya_type_transition_history");
            }

            return new ((), insert_id);
        }

        return error("Error while inserting data", resAdd);

    }

    remote function update_person_organization(int personId, int newOrgId, string transitionDate) returns PersonData|error? {
        Person|error? personRaw = db_client->queryRow(
            `SELECT *
            FROM person
            WHERE (id = ${personId});`
        );

        if !(personRaw is Person) {
            return error("Person does not exist");
        }

        Organization|error? orgRaw = db_client->queryRow(
            `SELECT *
            FROM organization
            WHERE (id = ${newOrgId});`
        );

        if !(orgRaw is Organization) {
            return error("New organization does not exist");
        }

        // add to person_organization_transition_history
        sql:ExecutionResult|error? resAdd = db_client->execute(
            `INSERT INTO person_organization_transition_history(
                    person_id,
                    previous_organization_id,
                    new_organization_id,
                    transition_date
                ) VALUES (
                    ${personId},
                    ${personRaw.organization_id},
                    ${newOrgId},
                    ${transitionDate}  
                );`
        );

        // update avinya_type_id in Person
        sql:ExecutionResult|error? resUpdate = db_client->execute(
            `UPDATE person
            SET organization_id = ${newOrgId}
            WHERE(id = ${personId});`
        );

        if (resUpdate is sql:ExecutionResult) {

            int? insert_count = resUpdate.affectedRowCount;
            if !(insert_count is int) {
                return error("Unable to update person's organization");
            }
        }
        else {
            return error("Error while updating data", resUpdate);
        }

        if (resAdd is sql:ExecutionResult) {

            int|string? insert_id = resAdd.lastInsertId;
            if !(insert_id is int) {
                return error("Unable to insert person_organization_transition_history");
            }

            return new ((), insert_id);
        }

        return error("Error while inserting data", resAdd);
    }

    remote function add_activity(Activity activity) returns ActivityData|error? {
        Activity|error? activityRaw = db_client->queryRow(
            `SELECT *
            FROM activity
            WHERE (name = ${activity.name} AND
            avinya_type_id = ${activity.avinya_type_id});`
        );

        if (activityRaw is Activity) {
            return error("Activity already exists. The name and avinya_type_id you are using is already used by another activity");
        }

        sql:ExecutionResult res = check db_client->execute(
            `INSERT INTO activity (
                name,
                description,
                avinya_type_id,
                notes
            ) VALUES (
                ${activity.name},
                ${activity.description},
                ${activity.avinya_type_id},
                ${activity.notes}
            );`
        );

        int|string? insert_id = res.lastInsertId;
        if !(insert_id is int) {
            return error("Unable to insert activity");
        }

        // Insert child and parent student relationships
        int[] child_activities_ids = activity.child_activities ?: [];
        int[] parent_activities_ids = activity.parent_activities ?: [];

        foreach int child_idx in child_activities_ids {
            _ = check db_client->execute(
                `INSERT INTO parent_child_activity (
                    child_activity_id,
                    parent_activity_id
                ) VALUES (
                    ${child_idx}, ${insert_id}
                );`
            );
        }

        foreach int parent_idx in parent_activities_ids {
            _ = check db_client->execute(
                `INSERT INTO parent_child_activity (
                    child_activity_id,
                    parent_activity_id
                ) VALUES (
                    ${insert_id}, ${parent_idx}
                );`
            );
        }

        return new ((), insert_id);

    }

    remote function add_activity_sequence_plan(ActivitySequencePlan activitySequencePlan) returns ActivitySequencePlanData|error? {
        sql:ExecutionResult res = check db_client->execute(
            `INSERT INTO activity_sequence_plan (
                activity_id,
                sequence_number,
                timeslot_number,
                person_id,
                organization_id
            ) VALUES (
                ${activitySequencePlan.activity_id},
                ${activitySequencePlan.sequence_number},
                ${activitySequencePlan.timeslot_number},
                ${activitySequencePlan.person_id},
                ${activitySequencePlan.organization_id}
            );`
        );

        int|string? insert_id = res.lastInsertId;
        if !(insert_id is int) {
            return error("Unable to insert activity sequence plan");
        }

        return new (insert_id);
    }

    remote function add_activity_instance(ActivityInstance activityInstance) returns ActivityInstanceData|error? {
        sql:ExecutionResult res = check db_client->execute(
            `INSERT INTO activity_instance (
                activity_id,
                name,
                description,
                place_id,
                daily_sequence,
                weekly_sequence,
                monthly_sequence,
                organization_id
            ) VALUES (
                ${activityInstance.activity_id},
                ${activityInstance.name},
                ${activityInstance.description},
                ${activityInstance.place_id},
                ${activityInstance.daily_sequence},
                ${activityInstance.weekly_sequence},
                ${activityInstance.monthly_sequence},
                ${activityInstance.organization_id}
            );`
        );

        int|string? insert_id = res.lastInsertId;
        if !(insert_id is int) {
            return error("Unable to insert activity instance");
        }

        return new ((), insert_id);
    }

    remote function add_activity_participant(ActivityParticipant activityParticipant) returns ActivityParticipantData|error? {
        ActivityParticipant|error? activityParticipantRaw = db_client->queryRow(
            `SELECT *
            FROM activity_participant
            WHERE (activity_instance_id = ${activityParticipant.activity_instance_id} AND
            person_id = ${activityParticipant.person_id});`
        );

        if (activityParticipantRaw is ActivityParticipant) {
            return error("Activity participant already exists. The activity_instance_id and person_id you are using is already used by another activity participant");
        }

        sql:ExecutionResult res = check db_client->execute(
            `INSERT INTO activity_participant (
                activity_instance_id,
                person_id,
                organization_id,
                start_date,
                end_date,
                role,
                notes
            ) VALUES (
                ${activityParticipant.activity_instance_id},
                ${activityParticipant.person_id},
                ${activityParticipant.organization_id},
                ${activityParticipant.start_date},
                ${activityParticipant.end_date},
                ${activityParticipant.role},
                ${activityParticipant.notes}
            );`
        );

        int|string? insert_id = res.lastInsertId;
        if !(insert_id is int) {
            return error("Unable to insert activity participant");
        }

        return new (insert_id);
    }

    remote function update_attendance(int attendanceId, string sign_out_time) returns ActivityParticipantAttendanceData|error? {
        ActivityParticipantAttendance|error? participantAttendanceRaw = db_client->queryRow(
            `SELECT *
            FROM activity_participant_attendance
            WHERE (id = ${attendanceId});`
        );

        if !(participantAttendanceRaw is ActivityParticipantAttendance) {
            return error("Activity participant does not exist");
        }

        // set sign_out_time
        sql:ExecutionResult|error res = db_client->execute(
            `UPDATE activity_participant_attendance
            SET sign_out_time = ${sign_out_time}
            WHERE(id = ${attendanceId});`
        );

        if (res is sql:ExecutionResult) {

            int? insert_count = res.affectedRowCount;
            if !(insert_count is int) {
                return error("Unable to update attendance sign out time");
            }

            return new ((), participantAttendanceRaw);
        }

        return error("Error while inserting data", res);
    }

    remote function add_vacancy(Vacancy vacancy) returns VacancyData|error? {
        sql:ExecutionResult res = check db_client->execute(
            `INSERT INTO vacancy (
                name,
                description,
                organization_id,
                avinya_type_id,
                evaluation_cycle_id,
                head_count
            ) VALUES (
                ${vacancy.name},
                ${vacancy.description},
                ${vacancy.organization_id},
                ${vacancy.avinya_type_id},
                ${vacancy.evaluation_cycle_id},
                ${vacancy.head_count}
            );`
        );

        int|string? insert_id = res.lastInsertId;
        if !(insert_id is int) {
            return error("Unable to insert evaluation");
        }

        return new ((), insert_id);
    }

    remote function add_person(Person person, int? avinya_type_id) returns PersonData|error? {
        AvinyaType avinya_type_raw;

        if (avinya_type_id != null) {
            avinya_type_raw = check db_client->queryRow(
                    `SELECT *
                    FROM avinya_type
                    WHERE id = ${avinya_type_id};`
                );
        } else {
            avinya_type_raw = check db_client->queryRow(
                `SELECT *
                FROM avinya_type
                WHERE global_type = "unassigned" AND  foundation_type = "unassigned";`
            );
        }

        Person|error? personRaw = db_client->queryRow(
            `SELECT *
            FROM person
            WHERE (email = ${person.email}  OR
            phone = ${person.phone} OR
            jwt_sub_id = ${person.jwt_sub_id}) AND 
            avinya_type_id = ${avinya_type_raw.id};`
        );

        if (personRaw is Person) {
            return error("Person already exists. The phone, email or the social login account you are using is already used by another person");
        }

        sql:ExecutionResult res = check db_client->execute(
            `INSERT INTO person (
                preferred_name,
                full_name,
                sex,
                organization_id,
                phone,
                email,
                avinya_type_id,
                permanent_address_id,
                mailing_address_id,
                jwt_sub_id,
                jwt_email,
                street_address
            ) VALUES (
                ${person.preferred_name},
                ${person.full_name},
                ${person.sex},
                ${person.organization_id},
                ${person.phone},
                ${person.email},
                ${avinya_type_raw.id},
                ${person.permanent_address_id},
                ${person.mailing_address_id},
                ${person.jwt_sub_id},
                ${person.jwt_email},
                ${person.street_address}
            );`
        );

        int|string? insert_id = res.lastInsertId;
        if !(insert_id is int) {
            return error("Unable to insert person");
        }

        // Insert child and parent relationships
        int[] child_student_ids = person.child_student ?: [];
        int[] parent_student_ids = person.parent_student ?: [];

        foreach int child_idx in child_student_ids {
            _ = check db_client->execute(
                `INSERT INTO parent_child_student (
                    child_student_id,
                    parent_student_id
                ) VALUES (
                    ${child_idx}, ${insert_id}
                );`
            );
        }

        foreach int parent_idx in parent_student_ids {
            _ = check db_client->execute(
                `INSERT INTO parent_child_student (
                    child_student_id,
                    parent_student_id
                ) VALUES (
                    ${insert_id}, ${parent_idx}
                );`
            );
        }

        return new ((), insert_id);

    }

    isolated resource function get asset(int? id, int? avinya_type_id) returns AssetData[]|error? {
        stream<Asset, error?> assets;
        lock {
            assets = db_client->query(
                `SELECT *
                FROM asset
                WHERE id = ${id} OR
                avinya_type_id = ${avinya_type_id}`
            );
        }

        AssetData[] assetDatas = [];

        check from Asset asset in assets
            do {
                AssetData|error assetData = new AssetData(0, 0, asset);
                if !(assetData is error) {
                    assetDatas.push(assetData);
                }
            };

        check assets.close();
        return assetDatas;
    }

    resource function get assets() returns AssetData[]|error {
        stream<Asset, error?> assets;
        lock {
            assets = db_client->query(
                `SELECT *
                FROM asset`
            );
        }

        AssetData[] assetDatas = [];

        check from Asset asset in assets
            do {
                AssetData|error assetData = new AssetData(0, 0, asset);
                if !(assetData is error) {
                    assetDatas.push(assetData);
                }
            };

        check assets.close();
        return assetDatas;
    }

    remote function add_asset(Asset asset) returns AssetData|error? {
        Asset|error? assetRaw = db_client->queryRow(
            `SELECT *
            FROM asset
            WHERE name = ${asset.name} AND
            serial_number = ${asset.serial_number};`
        );

        if (assetRaw is Asset) {
            return error("Asset already exists. The name or the serial number you are using is already used by another asset");
        }

        sql:ExecutionResult res = check db_client->execute(
            `INSERT INTO asset (
                name,
                manufacturer,
                model,
                serial_number,
                registration_number,
                description,
                avinya_type_id
            ) VALUES (
                ${asset.name},
                ${asset.manufacturer},
                ${asset.model},
                ${asset.serial_number},
                ${asset.registration_number},
                ${asset.description},
                ${asset.avinya_type_id}
            );`
        );

        int|string? insert_id = res.lastInsertId;
        if !(insert_id is int) {
            return error("Unable to insert asset");
        }

        return new (insert_id);
    }

    remote function update_asset(Asset asset) returns AssetData|error? {
        int id = asset.id ?: 0;
        if (id == 0) {
            return error("Unable to update Asset Data");
        }

        Asset|error? assetRaw = db_client->queryRow(
            `SELECT *
            FROM asset
            WHERE name = ${asset.name} AND
            serial_number = ${asset.serial_number};`

        );

        if !(assetRaw is Asset) {
            return error("Asset Data does not exist");
        }

        sql:ExecutionResult|error res = db_client->execute(
            `UPDATE asset SET
                name = ${asset.name},
                manufacturer = ${asset.manufacturer},
                model = ${asset.model},
                serial_number = ${asset.serial_number},
                registration_number = ${asset.registration_number},
                description = ${asset.description},
                avinya_type_id = ${asset.avinya_type_id}
            WHERE id = ${id};`
        );

        if (res is sql:ExecutionResult) {
            return new (id);
        } else {
            return error("Unable to update Asset Data");
        }
    }

    isolated resource function get supplier(int id) returns SupplierData|error? {
        return new SupplierData(id);
    }

    resource function get suppliers() returns SupplierData[]|error {
        stream<Supplier, error?> suppliers;
        lock {
            suppliers = db_client->query(
                `SELECT *
                FROM supplier`
            );
        }

        SupplierData[] supplierDatas = [];

        check from Supplier supplier in suppliers
            do {
                SupplierData|error supplierData = new SupplierData(0, supplier);
                if !(supplierData is error) {
                    supplierDatas.push(supplierData);
                }
            };

        check suppliers.close();
        return supplierDatas;
    }

    remote function add_supplier(Supplier supplier) returns SupplierData|error? {
        Supplier|error? supplierRaw = db_client->queryRow(
            `SELECT *
            FROM supplier
            WHERE name = ${supplier.name};`
        );

        if (supplierRaw is Supplier) {
            return error("Supplier already exists. The name you are using is already used by another supplier");
        }

        sql:ExecutionResult res = check db_client->execute(
            `INSERT INTO supplier (
                name,
                phone,
                email,
                address_id,
                description
            ) VALUES (
                ${supplier.name},
                ${supplier.phone},
                ${supplier.email},
                ${supplier.address_id},
                ${supplier.description}
            );`
        );

        int|string? insert_id = res.lastInsertId;
        if !(insert_id is int) {
            return error("Unable to insert supplier");
        }

        return new (insert_id);
    }

    remote function update_supplier(Supplier supplier) returns SupplierData|error? {
        int id = supplier.id ?: 0;
        if (id == 0) {
            return error("Unable to update Supplier Data");
        }

        Supplier|error? supplierRaw = db_client->queryRow(
            `SELECT *
            FROM supplier
            WHERE name = ${supplier.name};`
        );

        if !(supplierRaw is Supplier) {
            return error("Supplier Data does not exist");
        }

        sql:ExecutionResult|error res = db_client->execute(
            `UPDATE supplier SET
                name = ${supplier.name},
                phone = ${supplier.phone},
                email = ${supplier.email},
                address_id = ${supplier.address_id},
                description = ${supplier.description}
            WHERE id = ${id};`
        );

        if (res is sql:ExecutionResult) {
            return new (id);
        } else {
            return error("Unable to update Supplier Data");
        }
    }

    isolated resource function get consumable(int id) returns ConsumableData|error? {
        return new ConsumableData(id);
    }

    //     isolated resource function get consumableByUpdate(string updated,int avinya_type_id) returns ConsumableData[]|error {
    //     stream<Consumable, error?> consumables;
    //     lock {
    //         consumables = db_client->query(
    //             `SELECT * 
    //             FROM consumable 
    //             WHERE avinya_type_id = ${avinya_type_id} AND DATE_FORMAT(updated, '%Y-%m-%d %H:%i:%s') LIKE '${updated}%';
    // `
    //         );
    //     }

    //     ConsumableData[] consumableDatas = [];

    //     check from Consumable consumable in consumables
    //         do {
    //             ConsumableData|error consumableData = new ConsumableData(null, 0, consumable);
    //             if !(consumableData is error) {
    //                 consumableDatas.push(consumableData);
    //             }
    //         };

    //     check consumables.close();
    //     return consumableDatas;
    //     }

    isolated resource function get consumableByUpdate(string? updated, int? avinya_type_id) returns ConsumableData[]|error? {
        stream<Consumable, error?> consumables;
        string _updated = (updated == null ? "" : updated + "%");
        lock {
            consumables = db_client->query(
                `SELECT * FROM consumable WHERE avinya_type_id = ${avinya_type_id} AND DATE_FORMAT(updated, '%Y-%m-%d %H:%i:%s') LIKE ${_updated};`
            );
        }

        ConsumableData[] consumableDatas = [];

        check from Consumable consumable in consumables
            do {
                ConsumableData|error consumableData = new ConsumableData(0, null, 0, consumable);
                if !(consumableData is error) {
                    consumableDatas.push(consumableData);
                }
            };

        check consumables.close();
        return consumableDatas;
    }

    isolated resource function get consumables() returns ConsumableData[]|error? {
        stream<Consumable, error?> consumables;
        lock {
            consumables = db_client->query(
                `SELECT *
                FROM consumable;`
            );
        }

        ConsumableData[] consumableDatas = [];

        check from Consumable consumable in consumables
            do {
                ConsumableData|error consumableData = new ConsumableData(0, null, 0, consumable);
                if !(consumableData is error) {
                    consumableDatas.push(consumableData);
                }
            };

        check consumables.close();
        return consumableDatas;
    }

    resource function get activeActivityInstance() returns ActivityInstanceData[]|error {
        stream<ActivityInstance, error?> activityInstances;
        lock {
            activityInstances = db_client->query(
                `SELECT *
FROM activity_instance
WHERE name = "Admission Cycle" AND NOW() BETWEEN start_time AND end_time;`
            );
        }

        ActivityInstanceData[] activityInstanceDatas = [];

        check from ActivityInstance activity in activityInstances
            do {
                ActivityInstanceData|error activityInstanceData = new ActivityInstanceData(null, 0, activity);
                if !(activityInstanceData is error) {
                    activityInstanceDatas.push(activityInstanceData);
                }
            };

        check activityInstances.close();
        return activityInstanceDatas;
    }

    remote function add_consumable(Consumable consumable) returns ConsumableData|error? {
        Consumable|error? consumableRaw = db_client->queryRow(
            `SELECT *
            FROM consumable
            WHERE name = ${consumable.name} AND
            avinya_type_id = ${consumable.avinya_type_id};`
        );

        if (consumableRaw is Consumable) {
            return error("Consumable already exists. The name you are using is already used by another consumable");
        }

        sql:ExecutionResult res = check db_client->execute(
            `INSERT INTO consumable (
                name,
                description,
                manufacturer,
                model,
                serial_number,
                avinya_type_id
            ) VALUES (
                ${consumable.name},
                ${consumable.description},
                ${consumable.manufacturer},
                ${consumable.model},
                ${consumable.serial_number},
                ${consumable.avinya_type_id}
            );`
        );

        int|string? insert_id = res.lastInsertId;
        if !(insert_id is int) {
            return error("Unable to insert consumabe");
        }

        return new (insert_id);
    }

    remote function add_pcti_notes(Evaluation evaluation) returns EvaluationData|error? {
        ActivityInstance|error? activityRaw = db_client->queryRow(
            `SELECT *
            FROM activity_instance
            WHERE id = ${evaluation.activity_instance_id};`
        );

        if !(activityRaw is ActivityInstance) {
            return error("PCTI activity instance does not exist");
        }

        int|error? eval_criteria_id = db_client->queryRow(
            `SELECT id
            FROM evaluation_criteria
            WHERE evaluation_type = 'Activity Note';`
        );

        if !(eval_criteria_id is int) {
            return error("Evaluation criteria does not exist");
        }

        sql:ExecutionResult res = check db_client->execute(
            `INSERT INTO evaluation(
                evaluatee_id,
                evaluator_id,
                evaluation_criteria_id,
                activity_instance_id,
                notes
            ) VALUES(
                ${evaluation.evaluatee_id},
                ${evaluation.evaluator_id},
                ${eval_criteria_id},
                ${evaluation.activity_instance_id},
                ${evaluation.notes}
            );`
        );

        int|string? insert_id = res.lastInsertId;
        if !(insert_id is int) {
            return error("Unable to insert PCTI note");
        }

        return new (insert_id);
    }

    remote function update_consumable(Consumable consumable) returns ConsumableData|error? {
        int id = consumable.id ?: 0;
        if (id == 0) {
            return error("Unable to update Consumable Data");
        }

        Consumable|error? consumableRaw = db_client->queryRow(
            `SELECT *
            FROM consumable
            WHERE name = ${consumable.name} AND
            avinya_type_id = ${consumable.avinya_type_id};`
        );

        if !(consumableRaw is Consumable) {
            return error("Consumable Data does not exist");
        }

        sql:ExecutionResult|error res = db_client->execute(
            `UPDATE consumable SET
                name = ${consumable.name},
                description = ${consumable.description},
                manufacturer = ${consumable.manufacturer},
                model = ${consumable.model},
                serial_number = ${consumable.serial_number},
                avinya_type_id = ${consumable.avinya_type_id}
            WHERE id = ${id};`
        );

        if (res is sql:ExecutionResult) {
            return new (id);
        } else {
            return error("Unable to update Consumable Data");
        }
    }

    isolated resource function get resource_property(int id) returns ResourcePropertyData|error? {
        return new ResourcePropertyData(id);
    }

    resource function get resource_properties() returns ResourcePropertyData[]|error {
        stream<ResourceProperty, error?> resource_properties;
        lock {
            resource_properties = db_client->query(
                `SELECT *
                FROM resource_property`
            );
        }

        ResourcePropertyData[] resourcePropertyDatas = [];

        check from ResourceProperty resourceProperty in resource_properties
            do {
                ResourcePropertyData|error resourcePropertyData = new ResourcePropertyData(0, resourceProperty);
                if !(resourcePropertyData is error) {
                    resourcePropertyDatas.push(resourcePropertyData);
                }
            };

        check resource_properties.close();
        return resourcePropertyDatas;
    }

    remote function add_resource_property(ResourceProperty resourceProperty) returns ResourcePropertyData|error? {
        ResourceProperty|error? resourcePropertyRaw = db_client->queryRow(
            `SELECT *
            FROM resource_property
            WHERE property =  ${resourceProperty.property} AND
            asset_id = ${resourceProperty.asset_id};`
        );

        if (resourcePropertyRaw is ResourceProperty) {
            return error("Resource Property already exists. The name you are using is already used by another resource property");
        }

        sql:ExecutionResult res = check db_client->execute(
            `INSERT INTO resource_property (
                property,
                value,
                asset_id
            ) VALUES (
                ${resourceProperty.property},
                ${resourceProperty.value},
                ${resourceProperty.asset_id}
            );`
        );

        int|string? insert_id = res.lastInsertId;
        if !(insert_id is int) {
            return error("Unable to insert resource property");
        }

        return new (insert_id);
    }

    remote function update_resource_property(ResourceProperty resourceProperty) returns ResourcePropertyData|error? {
        int id = resourceProperty.id ?: 0;
        if (id == 0) {
            return error("Unable to update Resource Property Data");
        }

        ResourceProperty|error? resourcePropertyRaw = db_client->queryRow(
            `SELECT *
            FROM resource_property
            WHERE property =  ${resourceProperty.property} AND
            asset_id = ${resourceProperty.asset_id};`
        );

        if !(resourcePropertyRaw is ResourceProperty) {
            return error("Resource Property Data does not exist");
        }

        sql:ExecutionResult|error res = db_client->execute(
            `UPDATE resource_property SET
                property = ${resourceProperty.property},
                value = ${resourceProperty.value},
                consumable_id = ${resourceProperty.consumable_id},
                asset_id = ${resourceProperty.asset_id}
            WHERE id = ${id};`
        );

        if (res is sql:ExecutionResult) {
            return new (id);
        } else {
            return error("Unable to update Resource Property Data");
        }
    }

    isolated resource function get supply(int id) returns SupplyData|error? {
        return new SupplyData(id);
    }

    resource function get supplies() returns SupplyData[]|error {
        stream<Supply, error?> supplies;
        lock {
            supplies = db_client->query(
                `SELECT *
                FROM supply`
            );
        }

        SupplyData[] supplyDatas = [];

        check from Supply supply in supplies
            do {
                SupplyData|error supplyData = new SupplyData(0, supply);
                if !(supplyData is error) {
                    supplyDatas.push(supplyData);
                }
            };

        check supplies.close();
        return supplyDatas;
    }

    remote function add_supply(Supply supply) returns SupplyData|error? {
        Supply|error? supplyRaw = db_client->queryRow(
            `SELECT *
            FROM supply
            WHERE asset_id = ${supply.asset_id} AND
            supplier_id = ${supply.supplier_id};`
        );

        if (supplyRaw is Supply) {
            return error("Supply already exists. The name you are using is already used by another supply");
        }

        sql:ExecutionResult res = check db_client->execute(
            `INSERT INTO supply (
                asset_id,
                consumable_id,
                supplier_id,
                person_id,
                order_date,
                delivery_date,
                order_id,
                order_amount
            ) VALUES (
                ${supply.asset_id},
                ${supply.consumable_id},
                ${supply.supplier_id},
                ${supply.person_id},
                ${supply.order_date},
                ${supply.delivery_date},
                ${supply.order_id},
                ${supply.order_amount}
            );`
        );

        int|string? insert_id = res.lastInsertId;
        if !(insert_id is int) {
            return error("Unable to insert supply");
        }

        return new (insert_id);
    }

    remote function update_supply(Supply supply) returns SupplyData|error? {
        int id = supply.id ?: 0;
        if (id == 0) {
            return error("Unable to update supply Data");
        }

        Supply|error? supplyRaw = db_client->queryRow(
            `SELECT *
            FROM supply
            WHERE asset_id = ${supply.asset_id} AND
            supplier_id = ${supply.supplier_id};`
        );

        if !(supplyRaw is Supply) {
            return error("Supply Data does not exist");
        }

        sql:ExecutionResult|error res = db_client->execute(
            `UPDATE supply SET
                asset_id = ${supply.asset_id},
                consumable_id = ${supply.consumable_id},
                supplier_id = ${supply.supplier_id},
                person_id = ${supply.person_id},
                order_date = ${supply.order_date},
                delivery_date = ${supply.delivery_date},
                order_id = ${supply.order_id},
                order_amount = ${supply.order_amount}
            WHERE id = ${id};`
        );

        if (res is sql:ExecutionResult) {
            return new (id);
        } else {
            return error("Unable to update Supply Data");
        }
    }

    isolated resource function get resource_allocation(int? id, int? person_id) returns ResourceAllocationData[]|error? {
        stream<ResourceAllocation, error?> resource_allocations;
        lock {
            resource_allocations = db_client->query(
                `SELECT *
                FROM resource_allocation
                WHERE person_id = ${person_id} OR
                id = ${id}`
            );
        }

        ResourceAllocationData[] resourceAllocationDatas = [];

        check from ResourceAllocation resourceAllocation in resource_allocations
            do {
                ResourceAllocationData|error resourceAllocationData = new ResourceAllocationData(0, 0, resourceAllocation);
                if !(resourceAllocationData is error) {
                    resourceAllocationDatas.push(resourceAllocationData);
                }
            };

        check resource_allocations.close();
        return resourceAllocationDatas;
    }

    # Get All the Avinya Types for the asset
    # + return - Avinya Type Data
    isolated resource function get avinya_types_by_asset() returns AvinyaTypeData[]|error {
        stream<AvinyaType, error?> avinyaTypes;
        lock {
            avinyaTypes = db_client->query(
                `SELECT *
                FROM avinya_types_for_asset`
            );
        }

        AvinyaTypeData[] avinyaTypeDatas = [];

        check from AvinyaType avinyaType in avinyaTypes
            do {
                AvinyaTypeData|error avinyaTypeData = new AvinyaTypeData(0, avinyaType);
                if !(avinyaTypeData is error) {
                    avinyaTypeDatas.push(avinyaTypeData);
                }
            };

        check avinyaTypes.close();
        return avinyaTypeDatas;
    }

    # Get the Available Assets for the Avinya Type
    # + id - Avinya Type Id
    # + return - Asset Data
    isolated resource function get asset_by_avinya_type(int? id) returns AssetData[]|error? {
        stream<Asset, error?> assets;
        lock {
            assets = db_client->query(
                `call getAssetByAvinyaType(${id})`
            );
        }

        AssetData[] assetDatas = [];

        check from Asset asset in assets
            do {
                AssetData|error assetData = new AssetData(0, 0, asset);
                if !(assetData is error) {
                    assetDatas.push(assetData);
                }
            };

        check assets.close();
        return assetDatas;
    }

    resource function get resource_allocations() returns ResourceAllocationData[]|error {
        stream<ResourceAllocation, error?> resource_allocations;
        lock {
            resource_allocations = db_client->query(
                `SELECT *
                FROM resource_allocation
                `
            );
        }

        ResourceAllocationData[] resourceAllocationDatas = [];

        check from ResourceAllocation resourceAllocation in resource_allocations
            do {
                ResourceAllocationData|error resourceAllocationData = new ResourceAllocationData(0, 0, resourceAllocation);
                if !(resourceAllocationData is error) {
                    resourceAllocationDatas.push(resourceAllocationData);
                }
            };

        check resource_allocations.close();
        return resourceAllocationDatas;
    }

    remote function add_resource_allocation(ResourceAllocation resourceAllocation) returns ResourceAllocationData|error? {
        ResourceAllocation|error? resourceAllocationRaw = db_client->queryRow(
            `SELECT *
            FROM resource_allocation
            WHERE consumable_id = ${resourceAllocation.consumable_id} AND
            person_id = ${resourceAllocation.person_id};`
        );

        if (resourceAllocationRaw is ResourceAllocation) {
            return error("Resource Allocation already exists. The name you are using is already used by another resource allocation");
        }

        sql:ExecutionResult res = check db_client->execute(
            `INSERT INTO resource_allocation (
                requested,
                approved,
                allocated,
                asset_id,
                consumable_id,
                organization_id,
                person_id,
                quantity,
                start_date,
                end_date
            ) VALUES (
                ${resourceAllocation.requested},
                ${resourceAllocation.approved},
                ${resourceAllocation.allocated},
                ${resourceAllocation.asset_id},
                ${resourceAllocation.consumable_id},
                ${resourceAllocation.organization_id},
                ${resourceAllocation.person_id},
                ${resourceAllocation.quantity},
                ${resourceAllocation.start_date},
                ${resourceAllocation.end_date}
            );`
        );

        int|string? insert_id = res.lastInsertId;
        if !(insert_id is int) {
            return error("Unable to insert resource allocation");
        }

        return new (insert_id);
    }

    remote function update_resource_allocation(ResourceAllocation resourceAllocation) returns ResourceAllocationData|error? {
        int id = resourceAllocation.id ?: 0;
        if (id == 0) {
            return error("Unable to update resource allocation Data");
        }

        ResourceAllocation|error? resourceAllocationRaw = db_client->queryRow(
            `SELECT *
            FROM resource_allocation
            WHERE consumable_id = ${resourceAllocation.consumable_id} AND
            person_id = ${resourceAllocation.person_id};`
        );

        if !(resourceAllocationRaw is ResourceAllocation) {
            return error("Resource Allocation Data does not exist");
        }

        sql:ExecutionResult|error res = db_client->execute(
            `UPDATE resource_allocation SET
                requested = ${resourceAllocation.requested},
                approved = ${resourceAllocation.approved},
                allocated = ${resourceAllocation.allocated},
                asset_id = ${resourceAllocation.asset_id},
                consumable_id = ${resourceAllocation.consumable_id},
                organization_id = ${resourceAllocation.organization_id},
                person_id = ${resourceAllocation.person_id},
                quantity = ${resourceAllocation.quantity},
                start_date = ${resourceAllocation.start_date},
                end_date = ${resourceAllocation.end_date}
            WHERE id = ${id};`
        );

        if (res is sql:ExecutionResult) {
            return new (id);
        } else {
            return error("Unable to update resource allocation Data");
        }
    }

    isolated resource function get inventory(int id) returns InventoryData|error? {
        return new InventoryData(id);
    }

    resource function get inventories() returns InventoryData[]|error {
        stream<Inventory, error?> inventories;
        lock {
            inventories = db_client->query(
                `SELECT *
                FROM inventory`
            );
        }

        InventoryData[] inventoryDatas = [];

        check from Inventory inventory in inventories
            do {
                InventoryData|error inventoryData = new InventoryData(0, inventory);
                if !(inventoryData is error) {
                    inventoryDatas.push(inventoryData);
                }
            };

        check inventories.close();
        return inventoryDatas;
    }

    remote function add_inventory(Inventory inventory) returns InventoryData|error? {
        Inventory|error? inventoryRaw = db_client->queryRow(
            `SELECT *
            FROM inventory
            WHERE asset_id = ${inventory.asset_id} AND
            consumable_id = ${inventory.consumable_id};`
        );

        if (inventoryRaw is Inventory) {
            return error("Inventory already exists. The name you are using is already used by another inventory");
        }

        sql:ExecutionResult res = check db_client->execute(
            `INSERT INTO inventory (
                asset_id,
                consumable_id,
                organization_id,
                person_id,
                quantity,
                quantity_in,
                quantity_out
            ) VALUES (
                ${inventory.asset_id},
                ${inventory.consumable_id},
                ${inventory.organization_id},
                ${inventory.person_id},
                ${inventory.quantity},
                ${inventory.quantity_in},
                ${inventory.quantity_out}
            );`
        );

        int|string? insert_id = res.lastInsertId;
        if !(insert_id is int) {
            return error("Unable to insert inventory");
        }

        return new (insert_id);
    }

    remote function update_inventory(Inventory inventory) returns InventoryData|error? {
        int id = inventory.id ?: 0;
        if (id == 0) {
            return error("Unable to update inventory Data");
        }

        Inventory|error? inventoryRaw = db_client->queryRow(
            `SELECT *
            FROM inventory
            WHERE asset_id = ${inventory.asset_id} AND
            consumable_id = ${inventory.consumable_id};`
        );

        if !(inventoryRaw is Inventory) {
            return error("Inventory Data does not exist");
        }

        sql:ExecutionResult|error res = db_client->execute(
            `UPDATE inventory SET
                asset_id = ${inventory.asset_id},
                consumable_id = ${inventory.consumable_id},
                organization_id = ${inventory.organization_id},
                person_id = ${inventory.person_id},
                quantity = ${inventory.quantity},
                quantity_in = ${inventory.quantity_in},
                quantity_out = ${inventory.quantity_out}
            WHERE id = ${id};`
        );

        if (res is sql:ExecutionResult) {
            return new (id);
        } else {
            return error("Unable to update inventory Data");
        }
    }

    resource function get resource_allocations_report(int? organization_id, int? avinya_type_id) returns ResourceAllocationData[]|error {
        stream<ResourceAllocation, error?> resource_allocations;
        lock {
            resource_allocations = db_client->query(
                `SELECT *
	             FROM resource_allocation
	             WHERE asset_id in (select id from asset where avinya_type_id = ${avinya_type_id})
                 AND ( organization_id 
                 in (select child_org_id from parent_child_organization where parent_org_id 
                 in (select child_org_id from parent_child_organization where parent_org_id = ${organization_id}))
                 OR organization_id = ${organization_id})
                `
            );
        }

        ResourceAllocationData[] resourceAllocationDatas = [];

        check from ResourceAllocation resourceAllocation in resource_allocations
            do {
                ResourceAllocationData|error resourceAllocationData = new ResourceAllocationData(0, 0, resourceAllocation);
                if !(resourceAllocationData is error) {
                    resourceAllocationDatas.push(resourceAllocationData);
                }
            };

        check resource_allocations.close();
        return resourceAllocationDatas;
    }

    remote function add_duty_for_participant(DutyParticipant dutyparticipant) returns DutyParticipantData|error? {

        DutyParticipant|error? dutyParticipantRaw = db_client->queryRow(
            `SELECT *
            FROM duty_participant
            WHERE person_id = ${dutyparticipant.person_id};`
        );

        if (dutyParticipantRaw is DutyParticipant) {
            return error("already person assigned for duty");
        }

        sql:ExecutionResult res = check db_client->execute(
            `INSERT INTO duty_participant (
                activity_id,
                person_id,
                role
            ) VALUES (
                ${dutyparticipant.activity_id},
                ${dutyparticipant.person_id},
                ${dutyparticipant.role}
            );`
        );
        io:println(res);
        int|string? insert_id = res.lastInsertId;
        if !(insert_id is int) {
            return error("Unable to insert duty participant record");
        }

        return new (insert_id);
    }

    resource function get duty_participants(int? organization_id) returns DutyParticipantData[]|error {

        Organization child_organization_raw = check db_client->queryRow(
            `SELECT c.*
             FROM parent_child_organization pc
             JOIN organization c ON pc.child_org_id = c.id
             LEFT JOIN organization_metadata om_start ON c.id = om_start.organization_id
             LEFT JOIN organization_metadata om_end ON c.id = om_end.organization_id
             WHERE pc.parent_org_id = ${organization_id} AND (om_start.key_name = 'start_date' AND STR_TO_DATE(om_start.value, '%Y-%m-%d') <= CURDATE())
             AND (om_end.key_name = 'end_date' AND (om_end.value IS NULL OR STR_TO_DATE(om_end.value, '%Y-%m-%d') >= CURDATE()));`
        );

        stream<DutyParticipant, error?> duty_participants;
        lock {
            duty_participants = db_client->query(
            `SELECT * 
	         FROM  duty_participant
	         WHERE person_id IN (SELECT id FROM person 
             WHERE organization_id IN (select child_org_id from parent_child_organization where parent_org_id = ${child_organization_raw.id}));`
            );
        }

        DutyParticipantData[] dutyParticipantsDatas = [];

        check from DutyParticipant dutyParticipant in duty_participants
            do {
                DutyParticipantData|error dutyParticipantData = new DutyParticipantData(0, 0, 0, dutyParticipant);
                if !(dutyParticipantData is error) {
                    dutyParticipantsDatas.push(dutyParticipantData);
                }
            };
        check duty_participants.close();
        return dutyParticipantsDatas;
    }

    isolated resource function get activities_by_avinya_type(int? avinya_type_id) returns ActivityData[]|error? {

        stream<Activity, error?> activitiesByAvinyaType;

        lock {

            activitiesByAvinyaType = db_client->query(
                ` SELECT *
                FROM activity
                WHERE avinya_type_id = ${avinya_type_id};`
            );
        }

        ActivityData[] activityByAvinyaTypeDatas = [];

        check from Activity activityByAvinyaType in activitiesByAvinyaType
            do {
                ActivityData|error activityByAvinyaTypeData = new ActivityData((), (), (), activityByAvinyaType);
                if !(activityByAvinyaTypeData is error) {
                    activityByAvinyaTypeDatas.push(activityByAvinyaTypeData);
                }
            };

        check activitiesByAvinyaType.close();
        return activityByAvinyaTypeDatas;
    }

    remote function delete_duty_for_participant(int id) returns int?|error? {

        sql:ExecutionResult res = check db_client->execute(
            `DELETE FROM duty_participant WHERE id = ${id};`
        );

        int? delete_id = res.affectedRowCount;
        if (delete_id <= 0) {
            return error("Unable to delete duty for participant with id: " + id.toString());
        }

        return delete_id;
    }

    remote function update_duty_rotation_metadata(DutyRotationMetaDetails duty_rotation) returns DutyRotationMetaData|error? {
        int id = duty_rotation.id ?: 0;
        if (id == 0) {
            //return error("Unable to update duty rotation raw");
            log:printError("Unable to update duty rotation raw");
        }

        DutyRotationMetaDetails|error? duty_rotation_raw = db_client->queryRow(
            `SELECT *
            FROM duty_rotation_metadata
            WHERE id = ${id} ;`
        );

        if !(duty_rotation_raw is DutyRotationMetaDetails) {

            sql:ExecutionResult res = check db_client->execute(
            `INSERT INTO duty_rotation_metadata (
                start_date,
                end_date,
                organization_id
            ) VALUES (
                ${duty_rotation.start_date},
                ${duty_rotation.end_date},
                ${duty_rotation.organization_id}
             );`
            );

            io:println(res);
            int|string? insert_id = res.lastInsertId;
            if !(insert_id is int) {
                return error("Unable to insert duty rotation metadata record");
            }
            return new (insert_id);
        }
        io:println(duty_rotation.start_date);
        io:println(duty_rotation.end_date);

        sql:ExecutionResult|error res = db_client->execute(
            `UPDATE duty_rotation_metadata SET
                start_date = ${duty_rotation.start_date},
                end_date = ${duty_rotation.end_date}
             WHERE id= ${id} ;`
        );

        if (res is sql:ExecutionResult) {
            return new (id);
        } else {
            return error("unable to update duty rotation raw");
        }
    }

    isolated resource function get duty_rotation_metadata_by_organization(int? organization_id) returns DutyRotationMetaData|error? {

        DutyRotationMetaDetails|error? duty_rotation_metadata_raw = check db_client->queryRow(
            `SELECT *
            FROM duty_rotation_metadata
            WHERE organization_id = ${organization_id};`
        );

        if (duty_rotation_metadata_raw is DutyRotationMetaDetails) {
            return new (0, 0, duty_rotation_metadata_raw);
        }
        return error("Unable to find duty rotation  data by organization");
    }

    resource function get duty_participants_by_duty_activity_id(int? organization_id, int? duty_activity_id) returns DutyParticipantData[]|error {

        Organization child_organization_raw = check db_client->queryRow(
            `SELECT c.*
             FROM parent_child_organization pc
             JOIN organization c ON pc.child_org_id = c.id
             LEFT JOIN organization_metadata om_start ON c.id = om_start.organization_id
             LEFT JOIN organization_metadata om_end ON c.id = om_end.organization_id
             WHERE pc.parent_org_id = ${organization_id} AND (om_start.key_name = 'start_date' AND STR_TO_DATE(om_start.value, '%Y-%m-%d') <= CURDATE())
             AND (om_end.key_name = 'end_date' AND (om_end.value IS NULL OR STR_TO_DATE(om_end.value, '%Y-%m-%d') >= CURDATE()));`
        );

        stream<DutyParticipant, error?> duty_participants;
        lock {
            duty_participants = db_client->query(
            `SELECT * 
	         FROM  duty_participant
	         WHERE person_id IN (SELECT id FROM person 
             WHERE organization_id IN (select child_org_id from parent_child_organization where parent_org_id = ${child_organization_raw.id}))
             AND activity_id = ${duty_activity_id};`
            );
        }

        DutyParticipantData[] dutyParticipantsDatas = [];

        check from DutyParticipant dutyParticipant in duty_participants
            do {
                DutyParticipantData|error dutyParticipantData = new DutyParticipantData(0, 0, 0, dutyParticipant);
                if !(dutyParticipantData is error) {
                    dutyParticipantsDatas.push(dutyParticipantData);
                }
            };
        check duty_participants.close();
        return dutyParticipantsDatas;
    }

    remote function add_duty_attendance(ActivityParticipantAttendance duty_attendance) returns ActivityParticipantAttendanceData|error? {
        // only today's duty attendance can be added with this method 
        ActivityParticipantAttendance|error todayDutyParticipantAttendance = db_client->queryRow(
            `SELECT *
            FROM activity_participant_attendance
            WHERE person_id = ${duty_attendance.person_id} and 
            activity_instance_id = ${duty_attendance.activity_instance_id} and
            DATE(sign_in_time) = CURDATE();`
        );
        if (todayDutyParticipantAttendance is ActivityParticipantAttendance) {
            if (duty_attendance.sign_in_time != null) {

                return new (todayDutyParticipantAttendance.id);

            }
            else if (duty_attendance.sign_out_time != null) {
                todayDutyParticipantAttendance = db_client->queryRow(
                    `SELECT *
                    FROM activity_participant_attendance
                    WHERE person_id = ${duty_attendance.person_id} and 
                    activity_instance_id = ${duty_attendance.activity_instance_id} and
                    DATE(sign_out_time) = CURDATE();`
                );
                if (todayDutyParticipantAttendance is ActivityParticipantAttendance) {
                    return new (todayDutyParticipantAttendance.id);
                }
            }
        }
        sql:ExecutionResult res = check db_client->execute(
            `INSERT INTO activity_participant_attendance (
                activity_instance_id,
                person_id,
                sign_in_time,
                sign_out_time,
                in_marked_by,
                out_marked_by
            ) VALUES (
                ${duty_attendance.activity_instance_id},
                ${duty_attendance.person_id},
                ${duty_attendance.sign_in_time},
                ${duty_attendance.sign_out_time},
                ${duty_attendance.in_marked_by},
                ${duty_attendance.out_marked_by}
            );`
        );

        int|string? insert_id = res.lastInsertId;
        if !(insert_id is int) {
            return error("Unable to insert duty attendance");
        }

        return new (insert_id);
    }

    isolated resource function get duty_attendance_today(int? organization_id, int? activity_id) returns ActivityParticipantAttendanceData[]|error? {

        Organization child_organization_raw = check db_client->queryRow(
            `SELECT c.*
             FROM parent_child_organization pc
             JOIN organization c ON pc.child_org_id = c.id
             LEFT JOIN organization_metadata om_start ON c.id = om_start.organization_id
             LEFT JOIN organization_metadata om_end ON c.id = om_end.organization_id
             WHERE pc.parent_org_id = ${organization_id} AND (om_start.key_name = 'start_date' AND STR_TO_DATE(om_start.value, '%Y-%m-%d') <= CURDATE())
             AND (om_end.key_name = 'end_date' AND (om_end.value IS NULL OR STR_TO_DATE(om_end.value, '%Y-%m-%d') >= CURDATE()));`
        );

        stream<ActivityParticipantAttendance, error?> duty_attendance_records;

        lock {
            duty_attendance_records = db_client->query(
                `SELECT * 
                FROM activity_participant_attendance
                WHERE person_id IN (SELECT id FROM person 
                WHERE organization_id IN (select child_org_id from parent_child_organization where parent_org_id = ${child_organization_raw.id}))                 
                AND 
                activity_instance_id IN (SELECT id FROM activity_instance WHERE activity_id = ${activity_id} AND start_time >= CURDATE() AND end_time <= CURDATE() + INTERVAL 1 DAY);`
            );
        }

        ActivityParticipantAttendanceData[] dutyAttendanceDatas = [];

        check from ActivityParticipantAttendance duty_attendance_record in duty_attendance_records
            do {
                ActivityParticipantAttendanceData|error dutyParticipantAttendanceData = new ActivityParticipantAttendanceData(0, duty_attendance_record);
                if !(dutyParticipantAttendanceData is error) {
                    dutyAttendanceDatas.push(dutyParticipantAttendanceData);
                }
            };
        check duty_attendance_records.close();
        return dutyAttendanceDatas;
    }

    isolated resource function get duty_participant(int? person_id) returns DutyParticipantData|error? {

        DutyParticipant|error? dutyParticipantRaw = db_client->queryRow(
            `SELECT *
            FROM duty_participant
            WHERE person_id = ${person_id};`
        );

        if !(dutyParticipantRaw is DutyParticipant) {
            return error("duty participant data does not exist");
        }

        return new DutyParticipantData(0, 0, person_id);
    }

    remote function add_duty_evaluation(Evaluation duty_evaluation) returns EvaluationData|error? {

        Evaluation|error todayDutyEvaluation = db_client->queryRow(
            `SELECT *
            FROM evaluation
            WHERE evaluatee_id = ${duty_evaluation.evaluatee_id} and 
            activity_instance_id = ${duty_evaluation.activity_instance_id} and
            DATE(created) = CURDATE();`
        );

        if (todayDutyEvaluation is Evaluation) {
            if (duty_evaluation.evaluatee_id != null) {

                return new (todayDutyEvaluation.id);

            }
        }

        sql:ExecutionResult res = check db_client->execute(
            `INSERT INTO evaluation (
                evaluatee_id,
                evaluator_id,
                evaluation_criteria_id,
                activity_instance_id,
                response,
                notes,
                grade
            ) VALUES (
                ${duty_evaluation.evaluatee_id},
                ${duty_evaluation.evaluator_id},
                ${duty_evaluation.evaluation_criteria_id},
                ${duty_evaluation.activity_instance_id},
                ${duty_evaluation.response},
                ${duty_evaluation.notes},
                ${duty_evaluation.grade}
            );`
        );

        int|string? insert_id = res.lastInsertId;

        if !(insert_id is int) {
            return error("Unable to insert evaluation");
        }

        return new (insert_id);
    }

    isolated resource function get attendance_dashboard_data_by_date(int? organization_id, int? parent_organization_id, int? activity_id, string? from_date = "", string? to_date = "") returns AttendanceDashboardDataMain[]|error? {
        stream<AttendanceDashboardDataForQuery, error?> present_count;
        stream<AttendanceDashboardDataForQuery, error?> absent_count;
        stream<AttendanceDashboardDataForQuery, error?> late_attendance;
        stream<AttendanceDashboardDataForQuery, error?> present_count_duty;
        stream<AttendanceDashboardDataForQuery, error?> absent_count_duty;
        stream<AttendanceDashboardDataForQuery, error?> late_attendance_duty;
        decimal|error? students_raw = 0;
        decimal total_students_count = 0;

        if (organization_id != null) {
            int|error? avinya_type_id = db_client->queryRow(
            `SELECT p.avinya_type_id FROM organization o left join person p on o.id = p.organization_id WHERE o.id = ${organization_id} AND p.avinya_type_id NOT IN (99, 100) ORDER BY p.avinya_type_id LIMIT 1;`
        );
            io:println("Eval Criteria ID: ", (check avinya_type_id).toString());

            if !(avinya_type_id is int) {
                io:println("Eval Criteria ID: ", (check avinya_type_id).toString());
                return error("AvinyaType ID does not exist");
            }
            students_raw = db_client->queryRow(
            `SELECT CAST(COUNT(*) AS DECIMAL) AS total_students
                            FROM person p
                            JOIN organization o ON o.id = p.organization_id
                            WHERE p.avinya_type_id = ${avinya_type_id} AND p.id != 26
                            AND p.organization_id = ${organization_id};`
        );
        } else {
            students_raw = db_client->queryRow(
            `SELECT CAST(COUNT(*) AS DECIMAL) AS total_students
                            FROM person p
                            JOIN organization o ON o.id = p.organization_id
                            WHERE p.avinya_type_id IN (37, 10, 96) AND p.id != 26
                            AND p.organization_id IN (
                                                                    SELECT id
                                                                    FROM organization
                                                                    WHERE id IN (
                                                                        SELECT child_org_id
                                                                        FROM parent_child_organization
                                                                        WHERE parent_org_id IN (
                                                                            SELECT child_org_id
                                                                            FROM parent_child_organization
                                                                            WHERE parent_org_id = ${parent_organization_id}
                                                                        )
                                                                    )
                                                                );`
        );
        }

        if (students_raw is decimal) {
            io:println("Eval Criteria ID: ", students_raw.toString());
            total_students_count = students_raw;
        } else if (students_raw is error) {
            total_students_count = 0;
            io:println("Error while getting Eval Criteria ID: ", students_raw.message());
        }

        if (organization_id != null) {
            lock {
                int|error? avinya_type_id = db_client->queryRow(
            `SELECT p.avinya_type_id FROM organization o left join person p on o.id = p.organization_id WHERE o.id = ${organization_id} AND p.avinya_type_id NOT IN (99, 100) ORDER BY p.avinya_type_id LIMIT 1;`
        );
                io:println("Eval Criteria ID: ", (check avinya_type_id).toString());

                if !(avinya_type_id is int) {
                    io:println("Eval Criteria ID: ", (check avinya_type_id).toString());
                    return error("AvinyaType ID does not exist");
                }
                present_count = db_client->query(
                        `SELECT IFNULL(CAST(SUM(present_count) AS SIGNED), 0) AS present_count
                            FROM (SELECT COUNT(DISTINCT person_id) AS present_count
                                FROM activity_participant_attendance
                                WHERE sign_in_time IS NOT NULL
                                    AND activity_instance_id IN (SELECT id FROM activity_instance WHERE activity_id = 4 ORDER BY id DESC) 
                                    AND person_id IN (SELECT id FROM person WHERE avinya_type_id = ${avinya_type_id} AND organization_id = ${organization_id}) 
                                    AND DATE(sign_in_time) BETWEEN ${from_date} AND ${to_date}
                                GROUP BY DATE(sign_in_time)) AS counts;`
                    );
                absent_count = db_client->query(
                        `SELECT COUNT(p.id) AS absent_count
                            FROM person p
                            JOIN organization o ON o.id = p.organization_id
                            CROSS JOIN (
                                SELECT DISTINCT DATE(sign_in_time) as a_date
                                FROM activity_participant_attendance
                                WHERE DATE(sign_in_time) IS NOT NULL
                                    AND activity_instance_id IN (SELECT id FROM activity_instance WHERE activity_id = 4 ORDER BY id DESC)
                                    AND DATE(sign_in_time) BETWEEN ${from_date} AND ${to_date}
                            ) AS subquery
                            LEFT JOIN activity_participant_attendance a ON p.id = a.person_id AND DATE(a.sign_in_time) = subquery.a_date 
                            WHERE a.person_id IS NULL AND p.avinya_type_id = ${avinya_type_id} AND p.id != 26 AND organization_id = ${organization_id}
                            ORDER BY subquery.a_date DESC;`
                    );
                late_attendance = db_client->query(
                        `SELECT COUNT(*) AS late_attendance
                        FROM activity_participant_attendance apa
                        LEFT JOIN person p ON apa.person_id = p.id
                        WHERE apa.person_id IN (SELECT id FROM person WHERE organization_id = ${organization_id} AND avinya_type_id = ${avinya_type_id})
                        AND apa.activity_instance_id IN (SELECT id FROM activity_instance WHERE activity_id = 4)
                        AND DATE(apa.sign_in_time) BETWEEN ${from_date} AND ${to_date}
                        AND TIME_FORMAT(apa.sign_in_time, '%H:%i:%s') > '08:30:59';`
                    );
                present_count_duty = db_client->query(
                        `SELECT IFNULL(CAST(SUM(present_count_duty) AS SIGNED), 0) AS present_count_duty
                            FROM (SELECT COUNT(DISTINCT person_id) AS present_count_duty
                                FROM activity_participant_attendance
                                WHERE sign_in_time IS NOT NULL
                                    AND activity_instance_id IN (SELECT id FROM activity_instance WHERE activity_id = 11 ORDER BY id DESC) 
                                    AND person_id IN (SELECT id FROM person WHERE avinya_type_id = ${avinya_type_id} AND organization_id = ${organization_id}) 
                                    AND DATE(sign_in_time) BETWEEN ${from_date} AND ${to_date}
                                GROUP BY DATE(sign_in_time)) AS counts;`
                    );
                absent_count_duty = db_client->query(
                        `select COUNT(e.id) AS absent_count_duty FROM person p
                        JOIN organization o ON o.id = p.organization_id 
                        LEFT JOIN evaluation e ON p.id = e.evaluatee_id 
                        WHERE p.avinya_type_id = ${avinya_type_id} AND p.id != 26
                        AND e.evaluation_criteria_id=110
                        AND DATE(e.created) BETWEEN ${from_date} AND ${to_date}
                        AND p.id IN (SELECT id FROM person WHERE avinya_type_id = ${avinya_type_id} AND organization_id = ${organization_id});`
                    );
                late_attendance_duty = db_client->query(
                        `SELECT COUNT(*) AS late_attendance_duty
                        FROM activity_participant_attendance apa
                        LEFT JOIN person p ON apa.person_id = p.id
                        WHERE apa.person_id IN (SELECT id FROM person WHERE organization_id = ${organization_id} AND avinya_type_id = ${avinya_type_id})
                        AND apa.activity_instance_id IN (SELECT id FROM activity_instance WHERE activity_id = 11)
                        AND DATE(apa.sign_in_time) BETWEEN ${from_date} AND ${to_date}
                        AND TIME_FORMAT(apa.sign_in_time, '%H:%i:%s') > '14:00:00';`
                    );
            }
        } else {
            lock {
                present_count = db_client->query(
                            `SELECT COUNT(pa.person_id) AS present_count
                                FROM activity_participant_attendance pa
                                JOIN person p ON pa.person_id = p.id
                                WHERE pa.sign_in_time IS NOT NULL
                                    AND pa.activity_instance_id IN (
                                        SELECT id
                                        FROM activity_instance
                                        WHERE activity_id = 4
                                        ORDER BY id DESC
                                    )
                                    AND p.avinya_type_id IN (37, 10, 96)
                                    AND DATE(pa.sign_in_time) BETWEEN ${from_date} AND ${to_date}
                                    AND p.organization_id IN (
                                        SELECT id
                                        FROM organization
                                        WHERE id IN (
                                            SELECT child_org_id
                                            FROM parent_child_organization
                                            WHERE parent_org_id IN (
                                                SELECT child_org_id
                                                FROM parent_child_organization
                                                WHERE parent_org_id = ${parent_organization_id}
                                            )
                                        )
                                    );`
                        );
            }
            lock {
                absent_count = db_client->query(
                        `SELECT COUNT(p.id) AS absent_count
                            FROM person p
                            JOIN organization o ON o.id = p.organization_id
                            CROSS JOIN (
                                SELECT DISTINCT DATE(sign_in_time) as a_date
                                FROM activity_participant_attendance
                                WHERE DATE(sign_in_time) IS NOT NULL
                                    AND activity_instance_id IN (SELECT id FROM activity_instance WHERE activity_id = 4 ORDER BY id DESC)
                                    AND DATE(sign_in_time) BETWEEN ${from_date} AND ${to_date}
                            ) AS subquery
                            LEFT JOIN activity_participant_attendance a ON p.id = a.person_id AND DATE(a.sign_in_time) = subquery.a_date 
                            WHERE a.person_id IS NULL AND p.avinya_type_id IN (37, 10, 96) AND p.id != 26 AND o.avinya_type NOT IN (95, 97, 98)
                            AND p.organization_id IN (
                                                                    SELECT id
                                                                    FROM organization
                                                                    WHERE id IN (
                                                                        SELECT child_org_id
                                                                        FROM parent_child_organization
                                                                        WHERE parent_org_id IN (
                                                                            SELECT child_org_id
                                                                            FROM parent_child_organization
                                                                            WHERE parent_org_id = ${parent_organization_id}
                                                                        )
                                                                    )
                                                                )
                            ORDER BY subquery.a_date DESC;`
                    );
            }
            lock {
                late_attendance = db_client->query(
                            `SELECT COUNT(*) AS late_attendance
                                FROM activity_participant_attendance apa
                                LEFT JOIN person p ON apa.person_id = p.id
                                WHERE p.organization_id IN (
                                                                        SELECT id
                                                                        FROM organization
                                                                        WHERE id IN (
                                                                            SELECT child_org_id
                                                                            FROM parent_child_organization
                                                                            WHERE parent_org_id IN (
                                                                                SELECT child_org_id
                                                                                FROM parent_child_organization
                                                                                WHERE parent_org_id = ${parent_organization_id}
                                                                            )
                                                                        )
                                                                    )
                                AND avinya_type_id IN (37, 10, 96)
                                    AND apa.activity_instance_id IN (SELECT id FROM activity_instance WHERE activity_id = 4)
                                    AND DATE(apa.sign_in_time) BETWEEN ${from_date} AND ${to_date}
                                    AND TIME_FORMAT(apa.sign_in_time, '%H:%i:%s') > '08:30:59';`
                        );
            }
            lock {
                present_count_duty = db_client->query(
                        `SELECT COUNT(pa.person_id) AS present_count_duty
                                FROM activity_participant_attendance pa
                                JOIN person p ON pa.person_id = p.id
                                WHERE pa.sign_in_time IS NOT NULL
                                    AND pa.activity_instance_id IN (
                                        SELECT id
                                        FROM activity_instance
                                        WHERE activity_id = 11
                                        ORDER BY id DESC
                                    )
                                    AND p.avinya_type_id IN (37, 10, 96)
                                    AND DATE(pa.sign_in_time) BETWEEN ${from_date} AND ${to_date}
                                    AND p.organization_id IN (
                                        SELECT id
                                        FROM organization
                                        WHERE id IN (
                                            SELECT child_org_id
                                            FROM parent_child_organization
                                            WHERE parent_org_id IN (
                                                SELECT child_org_id
                                                FROM parent_child_organization
                                                WHERE parent_org_id = ${parent_organization_id}
                                            )
                                        )
                                    );`
                    );
            }
            lock {
                absent_count_duty = db_client->query(
                        `select COUNT(e.id) AS absent_count_duty FROM person p
JOIN organization o ON o.id = p.organization_id 
LEFT JOIN evaluation e ON p.id = e.evaluatee_id 
WHERE p.avinya_type_id IN (37, 10, 96) AND p.id != 26 AND o.avinya_type NOT IN (95, 97, 98)
AND e.evaluation_criteria_id=110
AND DATE(e.created) BETWEEN ${from_date} AND ${to_date}
AND p.organization_id IN (
						SELECT id
						FROM organization
						WHERE id IN (
							SELECT child_org_id
							FROM parent_child_organization
							WHERE parent_org_id IN (
								SELECT child_org_id
								FROM parent_child_organization
								WHERE parent_org_id = ${parent_organization_id}
							)
						)
					);`
                    );
            }
            lock {
                late_attendance_duty = db_client->query(
                            `SELECT COUNT(*) AS late_attendance_duty
                                FROM activity_participant_attendance apa
                                LEFT JOIN person p ON apa.person_id = p.id
                                WHERE p.organization_id IN (
                                                                        SELECT id
                                                                        FROM organization
                                                                        WHERE id IN (
                                                                            SELECT child_org_id
                                                                            FROM parent_child_organization
                                                                            WHERE parent_org_id IN (
                                                                                SELECT child_org_id
                                                                                FROM parent_child_organization
                                                                                WHERE parent_org_id = ${parent_organization_id}
                                                                            )
                                                                        )
                                                                    )
                                AND avinya_type_id IN (37, 10, 96)
                                    AND apa.activity_instance_id IN (SELECT id FROM activity_instance WHERE activity_id = 11)
                                    AND DATE(apa.sign_in_time) BETWEEN ${from_date} AND ${to_date}
                                    AND TIME_FORMAT(apa.sign_in_time, '%H:%i:%s') > '14:00:00';`
                        );
            }
        }
        AttendanceDashboardDataMain[] dashboardDatas = [];

        decimal days = 1;

        if (to_date != null && from_date != null) {
            lock {
                time:Utc toDate = check time:utcFromString(to_date + "T00:00:00Z");
                time:Utc fromDate = check time:utcFromString(from_date + "T00:00:00Z");
                int weekDaysDurationInSeconds = calculateWeekdays(toDate, fromDate);
                days = <decimal>weekDaysDurationInSeconds;
                io:println("Time taken days2 " + days.toString());
                string emailFormattedString = time:utcToEmailString(toDate, "Z");
                string dayAbbreviation = emailFormattedString.substring(0, 3);
                io:println(`Email formatted string: ${dayAbbreviation}`);
            }
        }

        // Process present_count stream
        lock {
            check from AttendanceDashboardDataForQuery attendance_record in present_count
                do {
                    decimal? totalStudent = 1;
                    if (<float>days == 0.0) {
                        totalStudent = total_students_count;
                        io:println("Time taken fff " + totalStudent.toString());
                    } else {
                        totalStudent = total_students_count * days;
                        io:println("Time taken ggg " + days.toString());
                        io:println("Time taken jjjj " + total_students_count.toString());

                    }
                    io:println("Time taken totalStudent " + totalStudent.toString());
                    io:println("Time taken total_students_count " + attendance_record.present_count.toString());
                    decimal? percentage = (attendance_record.present_count * 100) / totalStudent;
                    if (percentage is null) {
                        percentage = 0;
                    }
                    decimal roundedPercentage = 0;
                    if (percentage is decimal) {
                        roundedPercentage = decimal:round(percentage, 2);
                    }

                    AttendanceDashboardData attendanceData = {
                        title: "Daily Attendance",
                        numOfFiles: attendance_record.present_count,
                        svgSrc: "assets/icons/icons8-attendance-48.png",
                        color: "#FFA113",
                        percentage: roundedPercentage
                    };

                    AttendanceDashboardDataMain dashboardDataMain = {
                        attendance_dashboard_data: attendanceData
                    };

                    dashboardDatas.push(dashboardDataMain);
                };
        }

        // }
        // Process absent_count stream
        lock {
            check from AttendanceDashboardDataForQuery attendance_record in absent_count
                do {
                    decimal? totalStudent = 1;
                    if (<float>days == 0.0) {
                        totalStudent = total_students_count;
                    } else {
                        totalStudent = total_students_count * days;
                    }
                    io:println("Time taken totalStudent " + totalStudent.toString());
                    io:println("Time taken total_students_count " + attendance_record.present_count.toString());
                    decimal? percentage = (attendance_record.absent_count * 100) / totalStudent;
                    if (percentage is null) {
                        percentage = 0;
                    }
                    decimal roundedPercentage = 0;
                    if (percentage is decimal) {
                        roundedPercentage = decimal:round(percentage, 2);
                    }
                    AttendanceDashboardData attendanceData = {
                        title: "Absent Students",
                        numOfFiles: attendance_record.absent_count, // You need to set the appropriate value
                        svgSrc: "assets/icons/absent.png",
                        color: "#FFFF00", // Replace with the actual color value
                        percentage: roundedPercentage
                    };

                    AttendanceDashboardDataMain dashboardDataMain = {
                        attendance_dashboard_data: attendanceData
                    };

                    dashboardDatas.push(dashboardDataMain);
                };
        }
        // Process late_attendance stream
        lock {
            check from AttendanceDashboardDataForQuery attendance_record in late_attendance
                do {
                    decimal? totalStudent = 1;
                    if (<float>days == 0.0) {
                        totalStudent = total_students_count;
                    } else {
                        totalStudent = total_students_count * days;
                    }
                    io:println("Time taken totalStudent " + totalStudent.toString());
                    io:println("Time taken total_students_count " + attendance_record.present_count.toString());
                    decimal? percentage = (attendance_record.late_attendance * 100) / totalStudent;
                    if (percentage is null) {
                        percentage = 0;
                    }
                    decimal roundedPercentage = 0;
                    if (percentage is decimal) {
                        roundedPercentage = decimal:round(percentage, 2);
                    }
                    log:printInfo("Time Arrival");
                    log:printInfo(attendance_record.late_attendance.toString());
                    AttendanceDashboardData attendanceData = {
                        title: "Late Arrival",
                        numOfFiles: attendance_record.late_attendance, // You need to set the appropriate value
                        svgSrc: "assets/icons/late.png",
                        color: "#F61D1D", // Replace with the actual color value
                        percentage: roundedPercentage
                    };

                    AttendanceDashboardDataMain dashboardDataMain = {
                        attendance_dashboard_data: attendanceData
                    };

                    dashboardDatas.push(dashboardDataMain);
                };
        }
        // Process present_count_duty stream
        lock {
            check from AttendanceDashboardDataForQuery attendance_record in present_count_duty
                do {
                    decimal? totalStudent = 1;
                    if (<float>days == 0.0) {
                        totalStudent = total_students_count;
                    } else {
                        totalStudent = total_students_count * days;
                    }
                    io:println("Time taken totalStudent " + totalStudent.toString());
                    io:println("Time taken total_students_count " + attendance_record.present_count.toString());
                    decimal? percentage = (attendance_record.present_count_duty * 100) / totalStudent;
                    if (percentage is null) {
                        percentage = 0;
                    }
                    decimal roundedPercentage = 0;
                    if (percentage is decimal) {
                        roundedPercentage = decimal:round(percentage, 2);
                    }
                    AttendanceDashboardData attendanceData = {
                        title: "Present for Duty",
                        numOfFiles: attendance_record.present_count_duty, // You need to set the appropriate value
                        svgSrc: "assets/icons/duty.png",
                        color: "#1DBA28", // Replace with the actual color value
                        percentage: roundedPercentage
                    };

                    AttendanceDashboardDataMain dashboardDataMain = {
                        attendance_dashboard_data: attendanceData
                    };

                    dashboardDatas.push(dashboardDataMain);
                };
        }
        // Process absent_count_duty stream
        lock {
            check from AttendanceDashboardDataForQuery attendance_record in absent_count_duty
                do {
                    decimal? totalStudent = 1;
                    if (<float>days == 0.0) {
                        totalStudent = total_students_count;
                    } else {
                        totalStudent = total_students_count * days;
                    }
                    io:println("Time taken totalStudent " + totalStudent.toString());
                    io:println("Time taken total_students_count " + attendance_record.present_count.toString());
                    decimal? percentage = (attendance_record.absent_count_duty * 100) / totalStudent;
                    if (percentage is null) {
                        percentage = 0;
                    }
                    decimal roundedPercentage = 0;
                    if (percentage is decimal) {
                        roundedPercentage = decimal:round(percentage, 2);
                    }
                    AttendanceDashboardData attendanceData = {
                        title: "Absent for Duty",
                        numOfFiles: attendance_record.absent_count_duty, // You need to set the appropriate value
                        svgSrc: "assets/icons/absent.png",
                        color: "#007EE5", // Replace with the actual color value
                        percentage: roundedPercentage
                    };

                    AttendanceDashboardDataMain dashboardDataMain = {
                        attendance_dashboard_data: attendanceData
                    };

                    dashboardDatas.push(dashboardDataMain);
                };
        }
        // Process late_attendance_duty stream
        lock {
            check from AttendanceDashboardDataForQuery attendance_record in late_attendance_duty
                do {
                    decimal? totalStudent = 1;
                    if (<float>days == 0.0) {
                        totalStudent = total_students_count;
                    } else {
                        totalStudent = total_students_count * days;
                    }
                    io:println("Time taken totalStudent " + totalStudent.toString());
                    io:println("Time taken total_students_count " + attendance_record.present_count.toString());
                    decimal? percentage = (attendance_record.late_attendance_duty * 100) / totalStudent;
                    if (percentage is null) {
                        percentage = 0;
                    }
                    decimal roundedPercentage = 0;
                    if (percentage is decimal) {
                        roundedPercentage = decimal:round(percentage, 2);
                    }
                    AttendanceDashboardData attendanceData = {
                        title: "Late for Duty",
                        numOfFiles: attendance_record.late_attendance_duty, // You need to set the appropriate value
                        svgSrc: "assets/icons/late.png",
                        color: "#A700E5", // Replace with the actual color value
                        percentage: roundedPercentage
                    };

                    AttendanceDashboardDataMain dashboardDataMain = {
                        attendance_dashboard_data: attendanceData
                    };

                    dashboardDatas.push(dashboardDataMain);
                };
        }

        check present_count.close();
        check absent_count.close();
        check late_attendance.close();
        check present_count_duty.close();
        check absent_count_duty.close();
        check late_attendance_duty.close();
        log:printInfo("Time ffffffff");
        log:printInfo((dashboardDatas).toString());
        return dashboardDatas;
    }

    isolated resource function get attendance_missed_by_security(int? organization_id, int? parent_organization_id, string? from_date = "", string? to_date = "") returns ActivityParticipantAttendanceMissedBySecurityData[]|error? {

        stream<ActivityParticipantAttendanceMissedBySecurity, error?> attendance_missed_by_security_records;

        if (from_date != null && to_date != null) {

            if (organization_id != null) {

                lock {
                    int|error? avinya_type_id = db_client->queryRow(
            `SELECT p.avinya_type_id FROM organization o left join person p on o.id = p.organization_id WHERE o.id = ${organization_id} AND p.avinya_type_id NOT IN (99, 100) ORDER BY p.avinya_type_id LIMIT 1;`
        );
                    io:println("Eval Criteria ID: ", (check avinya_type_id).toString());

                    if !(avinya_type_id is int) {
                        io:println("Eval Criteria ID: ", (check avinya_type_id).toString());
                        return error("AvinyaType ID does not exist");
                    }
                    attendance_missed_by_security_records = db_client->query(
                `SELECT DATE(a.sign_in_time) AS sign_in_time,p.preferred_name,p.digital_id,o.description
                    FROM person p
                    JOIN activity_participant_attendance a ON p.id = a.person_id
                    JOIN activity_instance ai ON a.activity_instance_id = ai.id
                    JOIN organization o ON o.id = p.organization_id
                    WHERE p.avinya_type_id = ${avinya_type_id}
                        AND o.avinya_type NOT IN (95, 97, 98)
                        AND ai.activity_id = 1
                        AND a.sign_in_time IS NOT NULL
                        AND NOT EXISTS (
                            SELECT 1
                            FROM activity_participant_attendance a2
                            JOIN activity_instance ai2 ON a2.activity_instance_id = ai2.id
                            WHERE a2.person_id = p.id
                                AND DATE(a2.sign_in_time) = DATE(a.sign_in_time)
                                AND ai2.activity_id = 4
                        )
                        AND o.id = ${organization_id}
                        AND DATE(a.sign_in_time) BETWEEN ${from_date} AND ${to_date}
                    GROUP BY p.preferred_name,p.digital_id, sign_in_time, ai.id, p.organization_id
                    ORDER BY ai.id DESC;`
                );
                }
            } else {

                lock {

                    attendance_missed_by_security_records = db_client->query(
                `SELECT DATE(a.sign_in_time) AS sign_in_time,p.preferred_name,p.digital_id,o.description
                    FROM person p
                    JOIN activity_participant_attendance a ON p.id = a.person_id
                    JOIN activity_instance ai ON a.activity_instance_id = ai.id
                    JOIN organization o ON o.id = p.organization_id
                    WHERE p.avinya_type_id IN (37, 10, 96)
                        AND o.avinya_type NOT IN (95, 97, 98)
                        AND ai.activity_id = 1
                        AND a.sign_in_time IS NOT NULL
                        AND NOT EXISTS (
                            SELECT 1
                            FROM activity_participant_attendance a2
                            JOIN activity_instance ai2 ON a2.activity_instance_id = ai2.id
                            WHERE a2.person_id = p.id
                                AND DATE(a2.sign_in_time) = DATE(a.sign_in_time)
                                AND ai2.activity_id = 4
                        )
                        AND p.organization_id IN (
                                        SELECT id
                                        FROM organization
                                        WHERE id IN (
                                            SELECT child_org_id
                                            FROM parent_child_organization
                                            WHERE parent_org_id IN (
                                                SELECT child_org_id
                                                FROM parent_child_organization
                                                WHERE parent_org_id = ${parent_organization_id}
                                            )
                                        ))
                        AND DATE(a.sign_in_time) BETWEEN ${from_date} AND ${to_date}
                    GROUP BY p.preferred_name,p.digital_id, sign_in_time, ai.id, p.organization_id
                    ORDER BY ai.id DESC;`
                );
                }

            }

            ActivityParticipantAttendanceMissedBySecurityData[] attendanceMissedBySecurityDatas = [];

            check from ActivityParticipantAttendanceMissedBySecurity attendance_missed_by_security_record in attendance_missed_by_security_records
                do {
                    ActivityParticipantAttendanceMissedBySecurityData|error attendanceMissedBySecurityData = new ActivityParticipantAttendanceMissedBySecurityData(attendance_missed_by_security_record);
                    if !(attendanceMissedBySecurityData is error) {
                        attendanceMissedBySecurityDatas.push(attendanceMissedBySecurityData);
                    }
                };
            check attendance_missed_by_security_records.close();
            return attendanceMissedBySecurityDatas;

        } else {
            return error("Provide non-null values for both 'From Date' and 'To Date'.");
        }
    }

    isolated resource function get daily_students_attendance_by_parent_org(int? parent_organization_id) returns DailyActivityParticipantAttendanceByParentOrgData[]|error? {

        stream<DailyActivityParticipantAttendanceByParentOrg, error?> daily_activity_participant_attendance_by_parent_org_records;

        if (parent_organization_id != null) {

            lock {
                daily_activity_participant_attendance_by_parent_org_records = db_client->query(
                `SELECT 
                    COUNT(pa.person_id) AS present_count, 
                    o.description, 
                    (
                        SELECT COUNT(p_total.id) 
                        FROM person p_total
                        WHERE p_total.organization_id = o.id
                        AND p_total.avinya_type_id IN (37, 10, 96)
                    ) AS total_student_count
                FROM 
                    activity_participant_attendance pa
                JOIN 
                    person p ON pa.person_id = p.id
                LEFT JOIN 
                    organization o ON o.id = p.organization_id
                WHERE 
                    pa.sign_in_time IS NOT NULL
                    AND pa.activity_instance_id IN (
                        SELECT id
                        FROM activity_instance
                        WHERE activity_id = 4
                        ORDER BY id DESC
                    )
                    AND p.avinya_type_id IN (37, 10, 96)
                    AND DATE(pa.sign_in_time) = CURRENT_DATE()
                    AND p.organization_id IN (
                        SELECT id
                        FROM organization
                        WHERE id IN (
                            SELECT child_org_id
                            FROM parent_child_organization
                            WHERE parent_org_id IN (
                                SELECT child_org_id
                                FROM parent_child_organization
                                WHERE parent_org_id = ${parent_organization_id}
                            )
                        )
                    )
                GROUP BY 
                    p.organization_id, o.description, o.id;`
                );
            }

            int parentOrg = (parent_organization_id == 2) ? parent_organization_id : 0; //this is add for bandaragama academy

            DailyActivityParticipantAttendanceByParentOrgData[] dailyActivityParticipantAttendanceByParentOrgDatas = [];

            check from DailyActivityParticipantAttendanceByParentOrg daily_activity_participant_attendance_by_parent_org_record in daily_activity_participant_attendance_by_parent_org_records

                do {

                    if (parentOrg == 2) { // This code block is intended for the Bandaragama Academy.if other academy  add another if code block.
                        // This code block assigns the SVG source and color values for the six classes at the Bandaragama Academy.

                        string value = daily_activity_participant_attendance_by_parent_org_record.description ?: "";

                        if (value == "Dolphins") {
                            daily_activity_participant_attendance_by_parent_org_record.svg_src = "assets/icons/icons8-dolphin-100.png";
                            daily_activity_participant_attendance_by_parent_org_record.color = "0xFF2196F3";
                        }
                        if (value == "Bears") {

                            daily_activity_participant_attendance_by_parent_org_record.svg_src = "assets/icons/icons8-bear-96.png";
                            daily_activity_participant_attendance_by_parent_org_record.color = "0xFFE68A00";
                        }
                        if (value == "Bees") {

                            daily_activity_participant_attendance_by_parent_org_record.svg_src = "assets/icons/icons8-bees-64.png";
                            daily_activity_participant_attendance_by_parent_org_record.color = "0xFF008000";
                        }
                        if (value == "Eagles") {

                            daily_activity_participant_attendance_by_parent_org_record.svg_src = "assets/icons/icons8-eagle-96.png";
                            daily_activity_participant_attendance_by_parent_org_record.color = "0xFFD32F2F";
                        }
                        if (value == "Leopards") {

                            daily_activity_participant_attendance_by_parent_org_record.svg_src = "assets/icons/icons8-leopard-80.png";
                            daily_activity_participant_attendance_by_parent_org_record.color = "0xFF800080";
                        }
                        if (value == "Elephants") {

                            daily_activity_participant_attendance_by_parent_org_record.svg_src = "assets/icons/icons8-elephant-100.png";
                            daily_activity_participant_attendance_by_parent_org_record.color = "0xFFDAA520";
                        }
                        if (value == "IT") {

                            daily_activity_participant_attendance_by_parent_org_record.svg_src = "assets/icons/icons8-computer-96.png";
                            daily_activity_participant_attendance_by_parent_org_record.color = "0xFF008000";
                        }
                        if (value == "CS") {

                            daily_activity_participant_attendance_by_parent_org_record.svg_src = "assets/icons/icons8-customer-service-64.png";
                            daily_activity_participant_attendance_by_parent_org_record.color = "0xFFFF00FF";
                        }

                    }

                    DailyActivityParticipantAttendanceByParentOrgData|error dailyActivityParticipantAttendanceByParentOrgData = new DailyActivityParticipantAttendanceByParentOrgData(daily_activity_participant_attendance_by_parent_org_record);
                    if !(dailyActivityParticipantAttendanceByParentOrgData is error) {
                        dailyActivityParticipantAttendanceByParentOrgDatas.push(dailyActivityParticipantAttendanceByParentOrgData);
                    }
                };
            check daily_activity_participant_attendance_by_parent_org_records.close();
            return dailyActivityParticipantAttendanceByParentOrgDatas;

        } else {
            return error("Provide non-null value for parent organization id.");
        }
    }

    isolated resource function get total_attendance_count_by_date(int? organization_id, int? parent_organization_id, string? from_date = "", string? to_date = "") returns TotalActivityParticipantAttendanceCountByDateData[]|error? {

        stream<TotalActivityParticipantAttendanceCountByDate, error?> total_attendance_count_by_date_records;

        if (from_date != null && to_date != null) {

            if (organization_id != null) {

                lock {
                    int|error? avinya_type_id = db_client->queryRow(
            `SELECT p.avinya_type_id FROM organization o left join person p on o.id = p.organization_id WHERE o.id = ${organization_id} AND p.avinya_type_id NOT IN (99, 100) ORDER BY p.avinya_type_id LIMIT 1;`
        );
                    io:println("Eval Criteria ID: ", (check avinya_type_id).toString());

                    if !(avinya_type_id is int) {
                        io:println("Eval Criteria ID: ", (check avinya_type_id).toString());
                        return error("AvinyaType ID does not exist");
                    }
                    total_attendance_count_by_date_records = db_client->query(
                `SELECT 
                        attendance_date,
                        COUNT(DISTINCT person_id) AS daily_total
                    FROM (
                        SELECT 
                            DATE(sign_in_time) AS attendance_date,
                            person_id
                        FROM 
                            activity_participant_attendance
                        WHERE 
                            person_id IN (
                            SELECT id FROM person WHERE avinya_type_id = ${avinya_type_id} AND organization_id = ${organization_id}
                            )
                            AND activity_instance_id IN (
                                SELECT DISTINCT id 
                                FROM activity_instance 
                                WHERE activity_id = 4
                            ) 
                            AND DATE(sign_in_time) BETWEEN ${from_date} AND ${to_date}
                        GROUP BY 
                            DATE(sign_in_time), person_id
                    ) AS daily_counts
                    WHERE 
                        DAYOFWEEK(attendance_date) BETWEEN 2 AND 6
                    GROUP BY 
                        attendance_date
                    ORDER BY 
                        attendance_date DESC;`
                );
                }
            } else {

                lock {

                    total_attendance_count_by_date_records = db_client->query(
                `SELECT 
                        attendance_date,
                        COUNT(DISTINCT person_id) AS daily_total
                    FROM (
                        SELECT 
                            DATE(sign_in_time) AS attendance_date,
                            person_id
                        FROM 
                            activity_participant_attendance
                        WHERE 
                            person_id IN (
                                SELECT DISTINCT id 
                                FROM person 
                                WHERE avinya_type_id IN (37, 10, 96)
                                AND organization_id IN (
                                    SELECT DISTINCT id 
                                    FROM organization 
                                    WHERE id IN (
                                        SELECT DISTINCT child_org_id 
                                        FROM parent_child_organization 
                                        WHERE parent_org_id IN (
                                            SELECT DISTINCT child_org_id 
                                            FROM parent_child_organization 
                                            WHERE parent_org_id = ${parent_organization_id}
                                        )
                                    ) 
                                    AND avinya_type IN (87, 10, 96)
                                )
                            )
                            AND activity_instance_id IN (
                                SELECT DISTINCT id 
                                FROM activity_instance 
                                WHERE activity_id = 4
                            ) 
                            AND DATE(sign_in_time) BETWEEN ${from_date} AND ${to_date}
                        GROUP BY 
                            DATE(sign_in_time), person_id
                    ) AS daily_counts
                    WHERE 
                        DAYOFWEEK(attendance_date) BETWEEN 2 AND 6 
                    GROUP BY 
                        attendance_date
                    ORDER BY 
                        attendance_date DESC;`
                );
                }

            }

            TotalActivityParticipantAttendanceCountByDateData[] attendanceCountByDateDatas = [];

            check from TotalActivityParticipantAttendanceCountByDate attendance_count_by_date_record in total_attendance_count_by_date_records
                do {
                    TotalActivityParticipantAttendanceCountByDateData|error attendanceCountByDateData = new TotalActivityParticipantAttendanceCountByDateData(attendance_count_by_date_record);
                    if !(attendanceCountByDateData is error) {
                        attendanceCountByDateDatas.push(attendanceCountByDateData);
                    }
                };
            check total_attendance_count_by_date_records.close();
            return attendanceCountByDateDatas;

        } else {
            return error("Provide non-null values for both 'From Date' and 'To Date'.");
        }
    }

    isolated resource function get daily_attendance_summary_report(int? organization_id, int? avinya_type_id, string? from_date = "", string? to_date = "") returns DailyActivityParticipantAttendanceSummaryReportData[]|error? {

        stream<ActivityParticipantAttendanceSummaryReport, error?> daily_attendance_summary_report_records;

        if (from_date != null && to_date != null) {

            lock {

                daily_attendance_summary_report_records = db_client->query(
                                `SELECT
                                    DATE(pa.sign_in_time) AS sign_in_date,
                                    COUNT(pa.person_id) AS present_count,
                                    COUNT(CASE WHEN TIME_FORMAT(pa.sign_in_time, '%H:%i:%s') > '08:30:59' THEN 1 END) AS late_count,
                                    ts.total_count
                                FROM
                                    activity_participant_attendance pa
                                    JOIN person p ON pa.person_id = p.id
                                    JOIN (
                                        SELECT COUNT(*) AS total_count
                                        FROM person p
                                        JOIN organization o ON o.id = p.organization_id
                                        WHERE p.avinya_type_id = ${avinya_type_id}
                                        AND p.id != 26
                                        AND p.organization_id IN (
                                            SELECT id
                                            FROM organization
                                            WHERE id IN (
                                                SELECT child_org_id
                                                FROM parent_child_organization
                                                WHERE parent_org_id =${organization_id}
                                            )
                                        )
                                    ) ts
                                WHERE
                                    pa.sign_in_time IS NOT NULL
                                    AND pa.activity_instance_id IN (
                                        SELECT id
                                        FROM activity_instance
                                        WHERE activity_id = 4
                                    )
                                    AND p.avinya_type_id = ${avinya_type_id}
                                    AND DATE(pa.sign_in_time) BETWEEN ${from_date} AND ${to_date}
                                GROUP BY DATE(pa.sign_in_time), ts.total_count order by DATE(pa.sign_in_time) asc;`);

            }

            DailyActivityParticipantAttendanceSummaryReportData[] attendanceSummaryReportDatas = [];
            decimal? present_attendance_percentage = 0.0;
            decimal? late_attendance_percentage = 0.0;

            check from ActivityParticipantAttendanceSummaryReport attendance_summary_report_record in daily_attendance_summary_report_records

                do {

                    int? present_count = attendance_summary_report_record.present_count;

                    int? late_count = attendance_summary_report_record.late_count;

                    int? total_count = attendance_summary_report_record.total_count;

                    if (total_count > 0) {

                        present_attendance_percentage = (present_count * 100) / total_count;

                        late_attendance_percentage = (late_count * 100) / total_count;

                    } else {
                        present_attendance_percentage = 0;

                        late_attendance_percentage = 0;

                    }

                    // if (present_attendance_percentage is null) {
                    //     present_attendance_percentage = 0;
                    // }
                    // if(late_attendance_percentage is null){
                    //     late_attendance_percentage = 0;
                    // }

                    decimal roundedPresentAttendancePercentage = 0;
                    decimal roundedLateAttendancePercentage = 0;

                    if (present_attendance_percentage is decimal) {
                        roundedPresentAttendancePercentage = decimal:round(present_attendance_percentage, 2);
                    }

                    if (late_attendance_percentage is decimal) {
                        roundedLateAttendancePercentage = decimal:round(late_attendance_percentage, 2);
                    }

                    ActivityParticipantAttendanceSummaryReport attendanceSummaryData = {
                        sign_in_date: attendance_summary_report_record.sign_in_date,
                        present_count: present_count,
                        late_count: late_count,
                        total_count: total_count,
                        present_attendance_percentage: roundedPresentAttendancePercentage,
                        late_attendance_percentage: roundedLateAttendancePercentage
                    };

                    DailyActivityParticipantAttendanceSummaryReportData|error dailyAttendanceSummaryReportData = new DailyActivityParticipantAttendanceSummaryReportData(attendanceSummaryData);

                    if !(dailyAttendanceSummaryReportData is error) {
                        attendanceSummaryReportDatas.push(dailyAttendanceSummaryReportData);
                    }
                };
            check daily_attendance_summary_report_records.close();
            return attendanceSummaryReportDatas;

        } else {
            return error("Provide non-null values for both 'From Date' and 'To Date'.");
        }
    }

    isolated resource function get inventory_data_by_organization(int? organization_id, string? date = "") returns InventoryData[]|error? {

        stream<Inventory, error?> inventory_data;

        // first check if inventory data for date are already have
        int|error? check_inventory_data_for_date = check db_client->queryRow(
                        `SELECT 
                            CASE 
                                WHEN (
                                    SELECT COUNT(DISTINCT I.consumable_id)
                                    FROM inventory I
                                    WHERE I.organization_id = ${organization_id} 
                                    AND DATE(I.updated) = ${date}
                                ) = (
                                    SELECT COUNT(*)
                                    FROM consumable
                                ) THEN 1
                                ELSE 0
                            END AS all_consumables_present;`);

        if (check_inventory_data_for_date == 0) {

            int|error? check_least_updated_inventory_data_for_date = check db_client->queryRow(
                                            `SELECT 
                                                CASE 
                                                    WHEN (
                                                        SELECT COUNT(DISTINCT I.consumable_id)
                                                        FROM inventory I
                                                        INNER JOIN (
                                                            SELECT 
                                                                consumable_id, 
                                                                MAX(updated) AS max_updated_at
                                                            FROM 
                                                                inventory
                                                            WHERE 
                                                                organization_id = ${organization_id}
                                                            GROUP BY 
                                                                consumable_id
                                                        ) max_updated ON I.consumable_id = max_updated.consumable_id 
                                                            AND I.updated = max_updated.max_updated_at
                                                    ) = (
                                                        SELECT COUNT(*)
                                                        FROM consumable
                                                    ) THEN 1
                                                    ELSE 0
                                                END AS all_consumables_present;`);

            if (check_least_updated_inventory_data_for_date == 0) {

                inventory_data = db_client->query(
                            `SELECT 
                                    I.id,
                                    C.avinya_type_id,
                                    C.id AS consumable_id,
                                    I.organization_id,
                                    I.person_id,
                                    I.created,
                                    I.updated,
                                    COALESCE(I.quantity, 0.0) AS quantity,
                                    COALESCE(I.quantity_in, 0.0) AS quantity_in,
                                    COALESCE(I.quantity_out, 0.0) AS quantity_out,
                                    COALESCE(I.prev_quantity, 0.0) AS prev_quantity,
                                    RP.id AS resource_property_id,
                                    RP.value AS resource_property_value,
                                    C.name,
                                    C.description,
                                    C.manufacturer,
                                    CASE 
                                        WHEN COALESCE(I.quantity, 0.0) < COALESCE(C.threshold, 0.0) THEN 1
                                        ELSE 0
                                    END AS is_below_threshold
                                FROM 
                                    consumable C
                                LEFT JOIN 
                                    (SELECT * FROM inventory WHERE organization_id = ${organization_id}) I 
                                    ON C.id = I.consumable_id AND I.updated = (
                                        SELECT MAX(I2.updated)
                                        FROM inventory I2
                                        WHERE I2.consumable_id = C.id AND I2.organization_id = ${organization_id}
                                    )
                                LEFT JOIN 
                                    resource_property RP 
                                    ON C.id = RP.consumable_id;
                                `);
            } else {

                inventory_data = db_client->query(
                        `SELECT 
                            I.id,
                            I.avinya_type_id,
                            I.consumable_id,
                            I.organization_id,
                            I.person_id,
                            I.quantity,
                            I.quantity_in,
                            I.quantity_out,
                            I.prev_quantity,
                            I.created,
                            I.updated,
                            RP.id AS resource_property_id,
                            RP.value AS resource_property_value,
                            C.name,
                            C.description,
                            C.manufacturer,
                            CASE 
                                WHEN COALESCE(I.quantity, 0.0) < COALESCE(C.threshold, 0.0) THEN 1
                                ELSE 0
                            END AS is_below_threshold
                        FROM 
                            consumable C
                        INNER JOIN 
                            (
                                SELECT 
                                    I1.*
                                FROM 
                                    inventory I1
                                INNER JOIN 
                                    (
                                        SELECT 
                                            consumable_id, 
                                            MAX(updated) AS max_updated_at
                                        FROM 
                                            inventory
                                        WHERE 
                                            organization_id = ${organization_id}
                                        GROUP BY 
                                            consumable_id
                                    ) latest_inventory 
                                    ON I1.consumable_id = latest_inventory.consumable_id 
                                    AND I1.updated = latest_inventory.max_updated_at
                            ) I 
                            ON C.id = I.consumable_id
                        LEFT JOIN 
                            resource_property RP 
                            ON C.id = RP.consumable_id;
                        `);
            }

        } else {

            inventory_data = db_client->query(
                                `SELECT 
                                    I.id, 
                                    I.avinya_type_id, 
                                    I.consumable_id, 
                                    I.organization_id, 
                                    I.person_id, 
                                    I.quantity, 
                                    I.quantity_in, 
                                    I.quantity_out,
                                    I.prev_quantity,
                                    I.created,
                                    I.updated, 
                                    RP.id AS resource_property_id, 
                                    RP.value AS resource_property_value, 
                                    C.name, 
                                    C.description, 
                                    C.manufacturer,
                                    CASE 
                                        WHEN COALESCE(I.quantity, 0.0) < COALESCE(C.threshold, 0.0) THEN 1
                                        ELSE 0
                                    END AS is_below_threshold
                                FROM 
                                    inventory I
                                INNER JOIN 
                                    consumable C ON I.consumable_id = C.id
                                INNER JOIN 
                                    resource_property RP ON C.id = RP.consumable_id
                                INNER JOIN 
                                    (
                                        SELECT 
                                            consumable_id, 
                                            MAX(updated) AS latest_update 
                                        FROM 
                                            inventory 
                                        WHERE 
                                            organization_id = ${organization_id}
                                            AND DATE(updated) = ${date}
                                        GROUP BY 
                                            consumable_id
                                    ) Latest 
                                    ON I.consumable_id = Latest.consumable_id 
                                    AND I.updated = Latest.latest_update
                                WHERE 
                                    I.organization_id = ${organization_id}
                                    AND DATE(I.updated) = ${date};
                                `);
        }

        InventoryData[] inventoryDatas = [];

        check from Inventory inventory in inventory_data
            do {
                InventoryData|error inventoryData = new InventoryData(0, inventory);

                if !(inventoryData is error) {
                    inventoryDatas.push(inventoryData);
                }
            };

        check inventory_data.close();
        return inventoryDatas;
    }

    remote function consumable_replenishment(int person_id, int organization_id, string date, Inventory[] inventories) returns InventoryData[]|error? {

        InventoryData[] newlyAddedInventoryDatas = [];

        foreach Inventory inventory in inventories {

            sql:ExecutionResult response = check db_client->execute(
                `INSERT INTO inventory (
                    avinya_type_id,
                    consumable_id,
                    organization_id,
                    person_id,
                    quantity,
                    quantity_in,
                    prev_quantity,
                    created,
                    updated
                ) VALUES (
                    ${inventory.avinya_type_id},
                    ${inventory.consumable_id},
                    ${organization_id},
                    ${person_id},
                    ${inventory.quantity},
                    ${inventory.quantity_in},
                    ${inventory.prev_quantity},
                    ${date},
                    ${date}
                );`
            );

            int|string? insert_id = response.lastInsertId;
            if !(insert_id is int) {
                return error("Unable to insert inventories");
            } else {
                InventoryData|error newlyAddedInventoryData = new InventoryData(insert_id);
                if !(newlyAddedInventoryData is error) {
                    newlyAddedInventoryDatas.push(newlyAddedInventoryData);
                }
            }
        }
        return newlyAddedInventoryDatas;
    }

    remote function consumable_depletion(int person_id, int organization_id, string date, Inventory[] inventories) returns InventoryData[]|error? {

        InventoryData[] newlyAddedInventoryDepletionDatas = [];

        foreach Inventory inventory in inventories {

            sql:ExecutionResult response = check db_client->execute(
                `INSERT INTO inventory (
                    avinya_type_id,
                    consumable_id,
                    organization_id,
                    person_id,
                    quantity,
                    quantity_out,
                    prev_quantity,
                    created,
                    updated
                ) VALUES (
                    ${inventory.avinya_type_id},
                    ${inventory.consumable_id},
                    ${organization_id},
                    ${person_id},
                    ${inventory.quantity},
                    ${inventory.quantity_out},
                    ${inventory.prev_quantity},
                    ${date},
                    ${date}
                );`
            );

            int|string? insert_id = response.lastInsertId;
            if !(insert_id is int) {
                return error("Unable to insert inventory depletion data");
            } else {
                InventoryData|error newlyAddedInventoryDepletionData = new InventoryData(insert_id);
                if !(newlyAddedInventoryDepletionData is error) {
                    newlyAddedInventoryDepletionDatas.push(newlyAddedInventoryDepletionData);
                }
            }
        }
        return newlyAddedInventoryDepletionDatas;
    }

    isolated resource function get consumable_weekly_report(int? organization_id, string? from_date = "", string? to_date = "") returns InventoryData[]|error? {

        stream<Inventory, error?> weekly_consumable_summary_data;

        if (from_date != null && to_date != null) {

            lock {

                weekly_consumable_summary_data = db_client->query(
                                    `SELECT 
                                        I.id, 
                                        I.avinya_type_id, 
                                        I.consumable_id, 
                                        I.organization_id, 
                                        I.person_id, 
                                        I.prev_quantity, 
                                        COALESCE(SUM_In.quantity_in_sum, 0.00) AS quantity_in, 
                                        COALESCE(SUM_Out.quantity_out_sum, 0.00) AS quantity_out, 
                                        RP.id AS resource_property_id, 
                                        RP.value AS resource_property_value, 
                                        C.name, 
                                        C.description, 
                                        C.manufacturer,
                                        DATE(I.updated) AS updated
                                    FROM 
                                        inventory I
                                    INNER JOIN 
                                        consumable C ON I.consumable_id = C.id
                                    LEFT JOIN 
                                        resource_property RP ON C.id = RP.consumable_id
                                    INNER JOIN (
                                        SELECT 
                                            consumable_id, 
                                            DATE(updated) AS update_date, 
                                            MIN(updated) AS earliest_update 
                                        FROM 
                                            inventory 
                                        WHERE 
                                            organization_id = ${organization_id}
                                            AND DATE(updated) BETWEEN ${from_date} AND ${to_date}
                                        GROUP BY 
                                            consumable_id, DATE(updated)
                                    ) Earliest 
                                        ON I.consumable_id = Earliest.consumable_id 
                                        AND DATE(I.updated) = Earliest.update_date 
                                        AND I.updated = Earliest.earliest_update
                                    LEFT JOIN (
                                        SELECT 
                                            consumable_id, 
                                            DATE(updated) AS update_date, 
                                            SUM(quantity_in) AS quantity_in_sum 
                                        FROM 
                                            inventory 
                                        WHERE 
                                            organization_id = ${organization_id}
                                            AND quantity_out = 0.00
                                            AND DATE(updated) BETWEEN ${from_date} AND ${to_date}
                                        GROUP BY 
                                            consumable_id, DATE(updated)
                                    ) SUM_In 
                                        ON I.consumable_id = SUM_In.consumable_id 
                                        AND DATE(I.updated) = SUM_In.update_date
                                    LEFT JOIN (
                                        SELECT 
                                            consumable_id, 
                                            DATE(updated) AS update_date, 
                                            SUM(quantity_out) AS quantity_out_sum 
                                        FROM 
                                            inventory 
                                        WHERE 
                                            organization_id = ${organization_id}
                                            AND quantity_in = 0.00
                                            AND DATE(updated) BETWEEN ${from_date} AND ${to_date}
                                        GROUP BY 
                                            consumable_id, DATE(updated)
                                    ) SUM_Out 
                                        ON I.consumable_id = SUM_Out.consumable_id 
                                        AND DATE(I.updated) = SUM_Out.update_date
                                    WHERE 
                                        I.organization_id = ${organization_id}
                                        AND DATE(I.updated) BETWEEN ${from_date} AND ${to_date}
                                    ORDER BY 
                                        I.updated ASC;`);
            }

            InventoryData[] weeklyConsumableSummaryDatas = [];

            check from Inventory weekly_consumable_summary_record in weekly_consumable_summary_data
                do {
                    InventoryData|error weeklyConsumableSummaryData = new InventoryData(0, weekly_consumable_summary_record);

                    if !(weeklyConsumableSummaryData is error) {
                        weeklyConsumableSummaryDatas.push(weeklyConsumableSummaryData);
                    }
                };

            check weekly_consumable_summary_data.close();
            return weeklyConsumableSummaryDatas;

        } else {
            return error("Provide non-null values for both 'From Date' and 'To Date'.");
        }

    }

    remote function update_consumable_replenishment(Inventory[] inventories) returns InventoryData[]|error? {

        InventoryData[] updatedInventoryDatas = [];

        foreach Inventory inventory in inventories {

            int id = inventory.id ?: 0;

            sql:ExecutionResult res = check db_client->execute(
            `UPDATE inventory SET
                quantity = ${inventory.quantity},
                quantity_in = ${inventory.quantity_in},
                updated = ${inventory.updated}
            WHERE id = ${id};`
            );

            if (res.affectedRowCount == sql:EXECUTION_FAILED) {
                return error("Unable to update  consumable replenishment record");
            } else {
                InventoryData|error updatedInventoryData = new InventoryData(id);
                if !(updatedInventoryData is error) {
                    updatedInventoryDatas.push(updatedInventoryData);
                }
            }

        }
        return updatedInventoryDatas;
    }

    remote function update_consumable_depletion(Inventory[] inventories) returns InventoryData[]|error? {

        InventoryData[] updatedInventoryDatas = [];

        foreach Inventory inventory in inventories {

            int id = inventory.id ?: 0;

            sql:ExecutionResult res = check db_client->execute(
            `UPDATE inventory SET
                quantity = ${inventory.quantity},
                quantity_out = ${inventory.quantity_out},
                updated = ${inventory.updated}
            WHERE id = ${id};`
            );

            if (res.affectedRowCount == sql:EXECUTION_FAILED) {
                return error("Unable to update consumable depletion record");
            } else {
                InventoryData|error updatedInventoryData = new InventoryData(id);
                if !(updatedInventoryData is error) {
                    updatedInventoryDatas.push(updatedInventoryData);
                }
            }

        }
        return updatedInventoryDatas;
    }

    isolated resource function get consumable_monthly_report(int? organization_id, int? year, int? month) returns InventoryData[]|error? {

        stream<Inventory, error?> monthly_consumable_summary_data;

        if (year != null && month != null) {

            lock {

                string dateStr = string `${year}-${month}-01`;

                monthly_consumable_summary_data = db_client->query(
                                    `SELECT 
                                        C.id AS consumable_id,  
                                        COALESCE(SUM_In.quantity_in_sum, 0.00) AS quantity_in, 
                                        COALESCE(SUM_Out.quantity_out_sum, 0.00) AS quantity_out,
                                        RP.id AS resource_property_id, 
                                        RP.value AS resource_property_value,
                                        COALESCE(PrevMonthNet.quantity_net, 0.00) AS quantity
                                    FROM 
                                        consumable C
                                    LEFT JOIN 
                                        resource_property RP ON C.id = RP.consumable_id
                                    LEFT JOIN (
                                        SELECT 
                                            I.consumable_id, 
                                            SUM(I.quantity_in) AS quantity_in_sum
                                        FROM 
                                            inventory I
                                        WHERE 
                                            I.organization_id = ${organization_id}
                                            AND YEAR(I.updated) = ${year}
                                            AND MONTH(I.updated) = ${month}
                                            AND I.quantity_out = 0.00
                                        GROUP BY 
                                            I.consumable_id
                                    ) SUM_In ON C.id = SUM_In.consumable_id
                                    LEFT JOIN (
                                        SELECT 
                                            I.consumable_id, 
                                            SUM(I.quantity_out) AS quantity_out_sum
                                        FROM 
                                            inventory I
                                        WHERE 
                                            I.organization_id = ${organization_id}
                                            AND YEAR(I.updated) = ${year}
                                            AND MONTH(I.updated) = ${month}
                                            AND I.quantity_in = 0.00
                                        GROUP BY 
                                            I.consumable_id
                                    ) SUM_Out ON C.id = SUM_Out.consumable_id
                                    LEFT JOIN (
                                        SELECT 
                                            I.consumable_id, 
                                            SUM(I.quantity_in) - SUM(I.quantity_out) AS quantity_net
                                        FROM 
                                            inventory I
                                        WHERE 
                                            I.organization_id = ${organization_id}
                                            AND I.updated >= DATE_SUB(DATE(${dateStr}), INTERVAL 1 MONTH)
                                            AND I.updated < DATE(${dateStr})
                                        GROUP BY 
                                            I.consumable_id
                                    ) PrevMonthNet ON C.id = PrevMonthNet.consumable_id
                                    ORDER BY 
                                        C.id;`);
            }

            InventoryData[] monthlyConsumableSummaryDatas = [];

            check from Inventory monthly_consumable_summary_record in monthly_consumable_summary_data
                do {
                    InventoryData|error monthlyConsumableSummaryData = new InventoryData(0, monthly_consumable_summary_record);

                    if !(monthlyConsumableSummaryData is error) {
                        monthlyConsumableSummaryDatas.push(monthlyConsumableSummaryData);
                    }
                };

            check monthly_consumable_summary_data.close();
            return monthlyConsumableSummaryDatas;

        } else {
            return error("Provide non-null values for both 'year' and 'month'.");
        }

    }

    isolated resource function get consumable_yearly_report(int? organization_id, int? consumable_id, int? year) returns InventoryData[]|error? {

        stream<Inventory, error?> yearly_consumable_summary_data;

        if (year != null && consumable_id != null) {

            lock {

                yearly_consumable_summary_data = db_client->query(
                                    `SELECT 
                                        C.id AS consumable_id,
                                        CASE M.month
                                            WHEN 1 THEN 'January'
                                            WHEN 2 THEN 'February'
                                            WHEN 3 THEN 'March'
                                            WHEN 4 THEN 'April'
                                            WHEN 5 THEN 'May'
                                            WHEN 6 THEN 'June'
                                            WHEN 7 THEN 'July'
                                            WHEN 8 THEN 'August'
                                            WHEN 9 THEN 'September'
                                            WHEN 10 THEN 'October'
                                            WHEN 11 THEN 'November'
                                            WHEN 12 THEN 'December'
                                        END AS month_name,
                                        COALESCE(SUM_In.quantity_in_sum, 0.00) AS quantity_in, 
                                        COALESCE(SUM_Out.quantity_out_sum, 0.00) AS quantity_out,
                                        RP.id AS resource_property_id, 
                                        RP.value AS resource_property_value
                                    FROM 
                                        consumable C
                                    LEFT JOIN 
                                        resource_property RP ON C.id = RP.consumable_id
                                    JOIN (
                                        SELECT 1 AS month UNION ALL
                                        SELECT 2 AS month UNION ALL
                                        SELECT 3 AS month UNION ALL
                                        SELECT 4 AS month UNION ALL
                                        SELECT 5 AS month UNION ALL
                                        SELECT 6 AS month UNION ALL
                                        SELECT 7 AS month UNION ALL
                                        SELECT 8 AS month UNION ALL
                                        SELECT 9 AS month UNION ALL
                                        SELECT 10 AS month UNION ALL
                                        SELECT 11 AS month UNION ALL
                                        SELECT 12 AS month
                                    ) M ON 1=1
                                    LEFT JOIN (
                                        SELECT 
                                            I.consumable_id, 
                                            MONTH(I.updated) AS month,
                                            SUM(I.quantity_in) AS quantity_in_sum
                                        FROM 
                                            inventory I
                                        WHERE 
                                            I.organization_id = ${organization_id}
                                            AND I.consumable_id = ${consumable_id}
                                            AND YEAR(I.updated) = ${year}
                                            AND I.quantity_out = 0.00
                                        GROUP BY 
                                            I.consumable_id, MONTH(I.updated)
                                    ) SUM_In ON C.id = SUM_In.consumable_id AND M.month = SUM_In.month
                                    LEFT JOIN (
                                        SELECT 
                                            I.consumable_id, 
                                            MONTH(I.updated) AS month,
                                            SUM(I.quantity_out) AS quantity_out_sum
                                        FROM 
                                            inventory I
                                        WHERE 
                                            I.organization_id = ${organization_id}
                                            AND I.consumable_id = ${consumable_id}
                                            AND YEAR(I.updated) = ${year}
                                            AND I.quantity_in = 0.00
                                        GROUP BY 
                                            I.consumable_id, MONTH(I.updated)
                                    ) SUM_Out ON C.id = SUM_Out.consumable_id AND M.month = SUM_Out.month
                                    WHERE 
                                        C.id = ${consumable_id}
                                    ORDER BY 
                                        C.id, M.month;`);
            }

            InventoryData[] yearlyConsumableSummaryDatas = [];

            check from Inventory yearly_consumable_summary_data_record in yearly_consumable_summary_data
                do {
                    InventoryData|error yearlyConsumableSummaryData = new InventoryData(0, yearly_consumable_summary_data_record);

                    if !(yearlyConsumableSummaryData is error) {
                        yearlyConsumableSummaryDatas.push(yearlyConsumableSummaryData);
                    }
                };

            check yearly_consumable_summary_data.close();
            return yearlyConsumableSummaryDatas;

        } else {
            return error("Provide non-null values for both 'year' and 'consumable_id'.");
        }

    }

    // remote function add_vehicle_fuel_consumption(VehicleFuelConsumption vehicle_fuel_consumption) returns VehicleFuelConsumptionData|error? {

    //     sql:ExecutionResult res = check db_client->execute(
    //         `INSERT INTO vehicle_fuel_consumption (
    //             vehicle_id,
    //             date_time,
    //             reason_id,
    //             starting_meter,
    //             ending_meter,
    //             distance,
    //             comment
    //         ) VALUES (
    //             ${vehicle_fuel_consumption.vehicle_id},
    //             ${vehicle_fuel_consumption.date_time},
    //             ${vehicle_fuel_consumption.reason_id},
    //             ${vehicle_fuel_consumption.starting_meter},
    //             ${vehicle_fuel_consumption.ending_meter},
    //             ${vehicle_fuel_consumption.distance},
    //             ${vehicle_fuel_consumption.comment}
    //         );`
    //     );

    //     int|string? insert_id = res.lastInsertId;
    //     if !(insert_id is int) {
    //         return error("Unable to insert Vehicle Fuel Consumption record");
    //     }

    //     return new (insert_id);
    // }

    // isolated resource function get vehicle_fuel_consumption_by_date(int? organization_id, string? date = "") returns VehicleFuelConsumptionData[]|error? {
    //     stream<VehicleFuelConsumption, error?> vehicle_fuel_consumption_data;

    //     if (organization_id != null && date != null) {

    //         lock {
    //             vehicle_fuel_consumption_data = db_client->query(
    //                 `SELECT vfc.id,vfc.vehicle_id,vfc.date_time,vfc.reason_id,vfc.starting_meter,vfc.ending_meter,vfc.distance,vfc.comment,vfc.created,vfc.updated
    //                     FROM  vehicle_fuel_consumption vfc
    //                     INNER JOIN vehicle v ON vfc.vehicle_id = v.id
    //                     where v.organization_id = ${organization_id} and DATE(vfc.date_time) = ${date};`);
    //         }

    //         VehicleFuelConsumptionData[] vehicleFuelConsumptionDatas = [];

    //         check from VehicleFuelConsumption vehicle_fuel_consumption_data_record in vehicle_fuel_consumption_data
    //             do {
    //                 VehicleFuelConsumptionData|error vehicleFuelConsumptionData = new VehicleFuelConsumptionData(0, vehicle_fuel_consumption_data_record);
    //                 if !(vehicleFuelConsumptionData is error) {
    //                     vehicleFuelConsumptionDatas.push(vehicleFuelConsumptionData);
    //                 }
    //             };

    //         check vehicle_fuel_consumption_data.close();
    //         return vehicleFuelConsumptionDatas;

    //     } else {
    //         return error("Provide non-null values for both 'organization_id' and 'date'.");
    //     }

    // }
    // isolated resource function get vehicle_fuel_consumption_by_id(int? id) returns VehicleFuelConsumptionData|error? {
    //     if (id != null) {
    //         return new (id);
    //     } else {
    //         return error("Provide non-null value for id.");
    //     }
    // }

    // remote function update_vehicle_fuel_consumption(VehicleFuelConsumption vehicle_fuel_consumption) returns VehicleFuelConsumptionData|error? {
    //     int id = vehicle_fuel_consumption.id ?: 0;
    //     if (id == 0) {
    //         return error("Unable to update Vehicle Fuel Consumption record");
    //     }

    //     sql:ExecutionResult res = check db_client->execute(
    //         `UPDATE vehicle_fuel_consumption SET
    //             vehicle_id = ${vehicle_fuel_consumption.vehicle_id},
    //             date_time = ${vehicle_fuel_consumption.date_time},
    //             reason_id = ${vehicle_fuel_consumption.reason_id},
    //             starting_meter = ${vehicle_fuel_consumption.starting_meter},
    //             ending_meter = ${vehicle_fuel_consumption.ending_meter},
    //             distance = ${vehicle_fuel_consumption.distance},
    //             comment = ${vehicle_fuel_consumption.comment}
    //         WHERE id = ${id};`
    //     );

    //     if (res.affectedRowCount == sql:EXECUTION_FAILED) {
    //         return error("Unable to update Vehicle Fuel Consumption record");
    //     }

    //     return new (id);
    // }

    // remote function delete_vehicle_fuel_consumption_by_id(int? id) returns int?|error? {

    //     sql:ExecutionResult res = check db_client->execute(
    //         `DELETE FROM vehicle_fuel_consumption WHERE id = ${id};`
    //     );

    //     int? delete_id = res.affectedRowCount;
    //     io:println(delete_id);
    //     if (delete_id <= 0) {
    //         return error("Unable to delete vehicle_fuel_consumption with id: " + id.toString());
    //     }

    //     return delete_id;

    // }

    // isolated resource function get vehicles(int? organization_id) returns VehicleData[]|error? {
    //     stream<Vehicle, error?> vehicles_data;

    //     lock {
    //             vehicles_data = db_client->query(
    //                 `SELECT id,vehicle_number,person_id
    //                     from vehicle
    //                     where organization_id = ${organization_id};`);
    //     }

    //         VehicleData[] vehicleDatas = [];

    //         check from Vehicle vehicle_data_record in vehicles_data
    //             do {
    //                 VehicleData|error vehicleData = new VehicleData(0,0,vehicle_data_record);
    //                 if !(vehicleData is error) {
    //                     vehicleDatas.push(vehicleData);
    //                 }
    //             };

    //         check vehicles_data.close();
    //         return vehicleDatas;
    // }

    // isolated resource function get vehicle_reasons() returns VehicleReasonMetaData[]|error? {
    //     stream<VehicleReasonMetadata, error?> vehicle_reasons_data;

    //     lock {
    //             vehicle_reasons_data = db_client->query(
    //                 `SELECT id,reason
    //                     from vehicle_reason_metadata;`);
    //     }

    //         VehicleReasonMetaData[] vehicleReasonDatas = [];

    //         check from VehicleReasonMetadata vehicle_reason_data_record in vehicle_reasons_data
    //             do {
    //                 VehicleReasonMetaData|error vehicleReasonData = new VehicleReasonMetaData(0,vehicle_reason_data_record);
    //                 if !(vehicleReasonData is error) {
    //                     vehicleReasonDatas.push(vehicleReasonData);
    //                 }
    //             };

    //         check vehicle_reasons_data.close();
    //         return vehicleReasonDatas;
    // }

    isolated resource function get persons(int? organization_id, int? avinya_type_id) returns PersonData[]|error? {
        stream<Person, error?> persons_data;

        if (organization_id != null && organization_id != -1 && avinya_type_id != null) {
            lock {
                persons_data = db_client->query(
                    `SELECT *
                        from person p
                        where 
                        p.avinya_type_id = ${avinya_type_id} and
                        p.organization_id IN(
                            Select child_org_id
                            from parent_child_organization pco
                            where pco.parent_org_id = ${organization_id}
                        );`);
            }

        } else if (organization_id != null && organization_id == -1 && avinya_type_id != null) {

            lock {
                persons_data = db_client->query(
                    `SELECT *
                        from person p
                        where 
                        p.avinya_type_id = ${avinya_type_id};`);
            }
        } else {
            return error("Provide non-null values for both 'organization_id' and 'avinya_type_id'.");
        }
        PersonData[] personDatas = [];

        check from Person person_data_record in persons_data
            do {
                PersonData|error personData = new PersonData(null, 0, person_data_record);
                if !(personData is error) {
                    personDatas.push(personData);
                }
            };

        check persons_data.close();
        return personDatas;

    }

    isolated resource function get person_by_id(int? id) returns PersonData|error? {
        if (id != null) {
            return new (null, id);
        } else {
            return error("Provide non-null value for id.");
        }
    }

    remote function update_person(Person person, Address? permanent_address, City? permanent_address_city, Address? mailing_address, City? mailing_address_city) returns PersonData|error? {

        //starting the transaction
        boolean first_db_transaction_fail = false;
        boolean second_db_transaction_fail = false;
        boolean third_db_transaction_fail = false;

        sql:ExecutionResult permanent_address_res;
        sql:ExecutionResult mailing_address_res;

        int|string? permanent_address_insert_id = null;
        int|string? mailing_address_insert_id = null;

        string message = "";

        transaction {

            int permanent_address_id = permanent_address?.id ?: 0;

            Address|error? permanent_address_raw = db_client->queryRow(
                                                    `SELECT *
                                                    FROM address
                                                    WHERE id = ${permanent_address_id};`
                                                    );

            if (permanent_address_raw is Address) {
                io:println("Permanent Address is already exists!");

                if (permanent_address != null && permanent_address_city != null) {

                    permanent_address_res = check db_client->execute(
                    `UPDATE address SET
                        street_address = ${permanent_address?.street_address},
                        phone = ${permanent_address?.phone},
                        city_id = ${permanent_address_city?.id}
                    WHERE id = ${permanent_address_id};`);

                    permanent_address_insert_id = permanent_address_id;

                    if (permanent_address_res.affectedRowCount == sql:EXECUTION_FAILED) {
                        first_db_transaction_fail = true;
                        io:println("Unable to update permanent address record");
                        message = "Unable to update permanent address record";
                    }
                }

            } else {

                if (permanent_address != null && permanent_address_city != null) {

                    permanent_address_res = check db_client->execute(
                    `INSERT INTO address(
                            street_address,
                            phone,
                            city_id
                    ) VALUES(
                        ${permanent_address?.street_address},
                        ${permanent_address?.phone},
                        ${permanent_address_city?.id}
                    );`
                );

                    permanent_address_insert_id = permanent_address_res.lastInsertId;

                    if !(permanent_address_insert_id is int) {
                        first_db_transaction_fail = true;
                        io:println("Unable to insert permanent address");
                        message = "Unable to insert permanent address";
                    }
                }
            }

            int mailing_address_id = mailing_address?.id ?: 0;

            Address|error? mailing_address_raw = db_client->queryRow(
                                                    `SELECT *
                                                    FROM address
                                                    WHERE id = ${mailing_address_id};`
                                                    );

            if (mailing_address_raw is Address) {

                io:println("Mailing Address is already exists!");

                if (mailing_address != null && mailing_address_city != null) {

                    mailing_address_res = check db_client->execute(
                    `UPDATE address SET
                        street_address = ${mailing_address?.street_address},
                        phone = ${mailing_address?.phone},
                        city_id = ${mailing_address_city?.id}
                    WHERE id = ${mailing_address_id};`);

                    mailing_address_insert_id = mailing_address_id;

                    if (mailing_address_res.affectedRowCount == sql:EXECUTION_FAILED) {
                        second_db_transaction_fail = true;
                        io:println("Unable to update mailing address record");
                        message = "Unable to update mailing address record";
                    }
                }

            } else {

                if (mailing_address != null && mailing_address_city != null) {

                    mailing_address_res = check db_client->execute(
                    `INSERT INTO address(
                            street_address,
                            phone,
                            city_id
                    ) VALUES(
                        ${mailing_address?.street_address},
                        ${mailing_address?.phone},
                        ${mailing_address_city?.id}
                    );`
                );

                    mailing_address_insert_id = mailing_address_res.lastInsertId;

                    if !(mailing_address_insert_id is int) {
                        second_db_transaction_fail = true;
                        io:println("Unable to insert mailing address");
                        message = "Unable to insert mailing address";
                    }
                }

            }

            int person_id = person.id ?: 0;

            sql:ExecutionResult update_person_res = check db_client->execute(
                                                `UPDATE person SET
                                                    preferred_name = ${person.preferred_name},
                                                    full_name = ${person.full_name},
                                                    date_of_birth = ${person.date_of_birth},
                                                    sex = ${person.sex},
                                                    asgardeo_id = ${person.asgardeo_id},
                                                    jwt_sub_id = ${person.jwt_sub_id},
                                                    jwt_email = ${person.jwt_email},
                                                    permanent_address_id = ${permanent_address_insert_id},
                                                    mailing_address_id = ${mailing_address_insert_id},
                                                    phone = ${person.phone},
                                                    organization_id = ${person.organization_id},
                                                    avinya_type_id = ${person.avinya_type_id},
                                                    notes = ${person.notes},
                                                    nic_no = ${person.nic_no},
                                                    passport_no = ${person.passport_no},
                                                    id_no = ${person.id_no},
                                                    email = ${person.email},
                                                    street_address = ${person.street_address},
                                                    digital_id = ${person.digital_id},
                                                    avinya_phone = ${person.avinya_phone},
                                                    bank_name = ${person.bank_name},
                                                    bank_account_number = ${person.bank_account_number},
                                                    bank_account_name = ${person.bank_account_name},
                                                    academy_org_id = ${person.academy_org_id},
                                                    bank_branch = ${person.bank_branch},
                                                    current_job = ${person.current_job},
                                                    updated_by = ${person.updated_by}
                                                WHERE id = ${person_id};`);

            if (update_person_res.affectedRowCount == sql:EXECUTION_FAILED) {
                third_db_transaction_fail = true;
                io:println("Unable to update person record");
                message = "Unable to update person record";
            }

            if (first_db_transaction_fail ||
                second_db_transaction_fail ||
                third_db_transaction_fail) {

                rollback;
                return error(message);
            } else {

                // Commit the transaction if three updates are successful
                check commit;
                io:println("Transaction committed successfully!");
                return new (null, person_id);
            }
        }

    }

    remote function insert_person(Person person, Address? mailing_address, City? mailing_address_city) returns PersonData|error? {

        //starting the transaction
        boolean first_db_transaction_fail = false;
        boolean second_db_transaction_fail = false;
        boolean third_db_transaction_fail = false;

        int|string? mailing_address_insert_id = null;

        string message = "";

        transaction {

            Person|error? personRaw = db_client->queryRow(
                                        `SELECT *
                                        FROM person
                                        WHERE 
                                        nic_no = ${person.nic_no};`
                                    );

            if (personRaw is Person) {
                first_db_transaction_fail = true;
                io:println("Person already exists.");
                message = "Person already exists.";
            }

            if (mailing_address != null && mailing_address_city != null) {

                sql:ExecutionResult mailing_address_res = check db_client->execute(
                    `INSERT INTO address(
                            street_address,
                            phone,
                            city_id
                    ) VALUES(
                        ${mailing_address?.street_address},
                        ${mailing_address?.phone},
                        ${mailing_address_city?.id}
                    );`
                );

                mailing_address_insert_id = mailing_address_res.lastInsertId;

                if !(mailing_address_insert_id is int) {
                    second_db_transaction_fail = true;
                    io:println("Unable to insert mailing address");
                    message = "Unable to insert mailing address";
                }
            }

            sql:ExecutionResult insert_person_res = check db_client->execute(
                                                `INSERT INTO person(
                                                  preferred_name,
                                                  full_name,
                                                  date_of_birth,
                                                  sex,
                                                  mailing_address_id,
                                                  phone,
                                                  organization_id,
                                                  avinya_type_id,
                                                  notes,
                                                  nic_no,
                                                  passport_no,
                                                  id_no,
                                                  email,
                                                  street_address,
                                                  digital_id,
                                                  avinya_phone,
                                                  bank_name,
                                                  bank_account_number,
                                                  bank_account_name,
                                                  bank_branch,
                                                  created_by
                                                ) VALUES (
                                                  ${person.preferred_name},
                                                  ${person.full_name},
                                                  ${person.date_of_birth},
                                                  ${person.sex},
                                                  ${mailing_address_insert_id},
                                                  ${person.phone},
                                                  ${person.organization_id},
                                                  ${person.avinya_type_id},
                                                  ${person.notes},
                                                  ${person.nic_no},
                                                  ${person.passport_no},
                                                  ${person.id_no},
                                                  ${person.email},
                                                  ${person.street_address},
                                                  ${person.digital_id},
                                                  ${person.avinya_phone},
                                                  ${person.bank_name},
                                                  ${person.bank_account_number},
                                                  ${person.bank_account_name},
                                                  ${person.bank_branch},
                                                  ${person.created_by}
                                                );`);

            int|string? insert_person_id = insert_person_res.lastInsertId;

            if !(insert_person_id is int) {
                third_db_transaction_fail = true;
                io:println("Unable to insert person");
                message = "Unable to insert person";
            }

            if (first_db_transaction_fail ||
                second_db_transaction_fail ||
                third_db_transaction_fail) {

                rollback;
                return error(message);
            } else {

                // Commit the transaction if three updates are successful
                check commit;
                io:println("Transaction committed successfully!");
                return new (null, <int?>insert_person_id);
            }
        }

    }

    isolated resource function get districts() returns DistrictData[]|error? {
        stream<District, error?> districts_data;

        lock {
            districts_data = db_client->query(
                    `SELECT *
                        from district;`);
        }

        DistrictData[] districtDatas = [];

        check from District district_data_record in districts_data
            do {
                DistrictData|error districtData = new DistrictData(null, 0, district_data_record);
                if !(districtData is error) {
                    districtDatas.push(districtData);
                }
            };

        check districts_data.close();
        return districtDatas;
    }

    isolated resource function get cities(int? district_id) returns CityData[]|error? {
        stream<City, error?> cities_data;

        if (district_id != null && district_id != 0 && district_id > 0) {

            lock {
                cities_data = db_client->query(
                    `SELECT *
                        from city
                     where district_id=${district_id};`);
            }

            CityData[] cityDatas = [];

            check from City city_data_record in cities_data
                do {
                    CityData|error cityData = new CityData(null, 0, city_data_record);
                    if !(cityData is error) {
                        cityDatas.push(cityData);
                    }
                };

            check cities_data.close();
            return cityDatas;
        } else {
            return error("Provide valid value for district_id.");
        }
    }

    isolated resource function get all_organizations() returns OrganizationData[]|error? {
        stream<Organization, error?> organizations_data;

        lock {
            organizations_data = db_client->query(
                    `SELECT *
                        from organization;`);
        }

        OrganizationData[] organizationDatas = [];

        check from Organization organization_data_record in organizations_data
            do {
                OrganizationData|error organizationData = new OrganizationData(null, 0, organization_data_record);
                if !(organizationData is error) {
                    organizationDatas.push(organizationData);
                }
            };

        check organizations_data.close();
        return organizationDatas;
    }

    remote function add_monthly_leave_dates(MonthlyLeaveDates monthly_leave_dates) returns MonthlyLeaveDatesData|error? {

        string leaveDatesString = "";
        int totalLeaveDates = 0;
        decimal dailyAmount = 0.0;

        MonthlyLeaveDates|error? monthlyLeaveDatesRaw = db_client->queryRow(
            `SELECT *
            FROM monthly_leave_dates
            WHERE year = ${monthly_leave_dates.year} and month = ${monthly_leave_dates.month} and
            organization_id = ${monthly_leave_dates.organization_id};`
        );

        if (monthlyLeaveDatesRaw is MonthlyLeaveDates) {
            return error("A record for this organization id already exists for the same year and month.");
        }

        int[] leaveDates = monthly_leave_dates.leave_dates_list;

        foreach int date in leaveDates {
            leaveDatesString = leaveDatesString + date.toString() + ",";
            totalLeaveDates = totalLeaveDates + 1;
        }

        if (leaveDatesString.length() > 0) {
            leaveDatesString = leaveDatesString.substring(0, leaveDatesString.length() - 1);
        }

        int? totalSchoolDays = monthly_leave_dates.total_days_in_month - totalLeaveDates;

        CalendarMetadata|error? monthlyPaymentAmount = check db_client->queryRow(
            `SELECT *
            FROM calendar_metadata
            WHERE organization_id = ${monthly_leave_dates.organization_id};`
        );

        if (monthlyPaymentAmount is CalendarMetadata) {
            dailyAmount = monthlyPaymentAmount.monthly_payment_amount / totalSchoolDays ?: 0.0;
        }

        sql:ExecutionResult res = check db_client->execute(
            `INSERT INTO monthly_leave_dates (
                year,
                month,
                organization_id,
                leave_dates,
                daily_amount
            ) VALUES (
                ${monthly_leave_dates.year},
                ${monthly_leave_dates.month},
                ${monthly_leave_dates.organization_id},
                ${leaveDatesString},
                ${dailyAmount}
            );`
        );

        int|string? insert_id = res.lastInsertId;
        if !(insert_id is int) {
            return error("Unable to insert Monthly Leave Dates record");
        }

        return new (insert_id);
    }

    remote function update_monthly_leave_dates(MonthlyLeaveDates monthly_leave_dates) returns MonthlyLeaveDatesData|error? {

        int id = monthly_leave_dates.id ?: 0;
        if (id == 0) {
            return error("Unable to update Monthly Leave Dates record");
        }

        string leaveDatesString = "";
        int totalLeaveDates = 0;
        decimal dailyAmount = 0.0;

        int[] leaveDates = monthly_leave_dates.leave_dates_list;

        foreach int date in leaveDates {
            leaveDatesString = leaveDatesString + date.toString() + ",";
            totalLeaveDates = totalLeaveDates + 1;
        }

        if (leaveDatesString.length() > 0) {
            leaveDatesString = leaveDatesString.substring(0, leaveDatesString.length() - 1);
        }

        int? totalSchoolDays = monthly_leave_dates.total_days_in_month - totalLeaveDates;

        CalendarMetadata|error? monthlyPaymentAmount = check db_client->queryRow(
            `SELECT *
            FROM calendar_metadata
            WHERE organization_id = ${monthly_leave_dates.organization_id};`
        );

        if (monthlyPaymentAmount is CalendarMetadata) {
            dailyAmount = monthlyPaymentAmount.monthly_payment_amount / totalSchoolDays ?: 0.0;
        }

        sql:ExecutionResult res = check db_client->execute(
            `UPDATE monthly_leave_dates SET
                year = ${monthly_leave_dates.year},
                month = ${monthly_leave_dates.month},
                organization_id = ${monthly_leave_dates.organization_id},
                leave_dates = ${leaveDatesString},
                daily_amount = ${dailyAmount}
            WHERE id = ${id};`
        );

        if (res.affectedRowCount == sql:EXECUTION_FAILED) {
            return error("Unable to update Monthly Leave Dates record");
        }

        return new (id);
    }

    isolated resource function get monthly_leave_dates_record_by_id(int organization_id, int year, int month) returns MonthlyLeaveDatesData|error? {
        if ((organization_id is int) && (year is int) && (month is int)) {

            MonthlyLeaveDates|error? monthly_leave_dates_raw = db_client->queryRow(
            `SELECT *
            FROM monthly_leave_dates
            WHERE organization_id = ${organization_id} and 
            year = ${year} and month = ${month} ;`);

            if (monthly_leave_dates_raw is MonthlyLeaveDates) {
                return new (0, monthly_leave_dates_raw);
            } else {
                // Return a new empty MonthlyLeaveDates object if no record is found
                MonthlyLeaveDates emptyLeaveDates = {
                    id: null,
                    year: null,
                    month: null,
                    organization_id: null,
                    leave_dates_list: [],
                    daily_amount: null,
                    created: null,
                    updated: null,
                    total_days_in_month: null,
                    leave_dates: null
                };
                return new (0, emptyLeaveDates);
            }
        }
    }

    isolated resource function get calendar_metadata_by_org_id(int organization_id) returns CalendarMetaData|error? {

        if (organization_id is int) {

            CalendarMetadata|error? calendar_metadata_raw = db_client->queryRow(
            `SELECT *
            FROM calendar_metadata
            WHERE organization_id = ${organization_id} ;`);

            if (calendar_metadata_raw is CalendarMetadata) {
                return new (0, calendar_metadata_raw);
            } else {
                // Return a new empty Calendar Metadata object if no record is found
                CalendarMetadata emptyCalendarMetadata = {
                    id: null,
                    organization_id: organization_id,
                    monthly_payment_amount: 0.0
                };
                return new (0, emptyCalendarMetadata);
            }
        }
    }

}

isolated function calculateWeekdays(time:Utc toDate, time:Utc fromDate) returns int {
    int weekdays = 0;
    time:Utc currentDate = fromDate;

    while currentDate <= toDate {
        time:Civil currentDateCivil = time:utcToCivil(currentDate);
        if (time:SUNDAY < currentDateCivil.dayOfWeek && currentDateCivil.dayOfWeek < time:SATURDAY) {
            weekdays += 1;
        }
        currentDate = time:utcAddSeconds(currentDate, 86400);
    }

    return weekdays;
}

function padStartWithZeros(string str, int len) returns string {
    int strLen = str.length();
    if (strLen >= len) {
        return str;
    }
    int numZeros = len - strLen;
    string paddedStr = "";
    while (numZeros > 0) {
        paddedStr = paddedStr + "0";
        numZeros = numZeros - 1;
    }
    return paddedStr + str;
}

isolated function updateDutyParticipantsRotationCycle() returns error? {

    stream<DutyRotationMetaDetails, error?> duty_rotation_raw;

    lock {

        duty_rotation_raw = db_client->query(
                `SELECT *
            FROM duty_rotation_metadata
            WHERE CURDATE() > DATE(end_date);`
            );
    }

    check from DutyRotationMetaDetails duty_rotation_meta_data in duty_rotation_raw
        do {

            string start_date = <string>duty_rotation_meta_data.start_date;
            string end_date = <string>duty_rotation_meta_data.end_date;

            time:Utc start_date_in_utc = check time:utcFromString(start_date);
            time:Utc end_date_in_utc = check time:utcFromString(end_date);

            time:Seconds difference_in_seconds = time:utcDiffSeconds(end_date_in_utc, start_date_in_utc);

            // calculate starting date
            time:Utc next_starting_date = time:utcAddSeconds(end_date_in_utc, 259200); // 3 days = 259200 seconds

            // calculate  ending date
            time:Utc next_ending_date = time:utcAddSeconds(next_starting_date, difference_in_seconds);

            string utcStringOfNextStartingDate = time:utcToString(next_starting_date);
            string utcStringOfNextEndingDate = time:utcToString(next_ending_date);

            sql:ExecutionResult res = check db_client->execute(
                                `UPDATE duty_rotation_metadata SET
                                start_date = ${utcStringOfNextStartingDate},
                                end_date = ${utcStringOfNextEndingDate}               
                                WHERE organization_id = ${duty_rotation_meta_data.organization_id};`
                            );
            //log:printInfo("=====================");
            if (res.affectedRowCount == sql:EXECUTION_FAILED) {
                return error("Execution failed.unable to update duty rotation meta data raw");
            }

            Organization child_organization_raw = check db_client->queryRow(
            `SELECT c.*
             FROM parent_child_organization pc
             JOIN organization c ON pc.child_org_id = c.id
             LEFT JOIN organization_metadata om_start ON c.id = om_start.organization_id
             LEFT JOIN organization_metadata om_end ON c.id = om_end.organization_id
             WHERE pc.parent_org_id = ${duty_rotation_meta_data.organization_id} AND (om_start.key_name = 'start_date' AND STR_TO_DATE(om_start.value, '%Y-%m-%d') <= CURDATE())
             AND (om_end.key_name = 'end_date' AND (om_end.value IS NULL OR STR_TO_DATE(om_end.value, '%Y-%m-%d') >= CURDATE()));`
        );

            stream<DutyParticipant, error?> duty_participants;
            lock {
                duty_participants = db_client->query(
            `SELECT * 
	         FROM  duty_participant
	         WHERE person_id IN (SELECT id FROM person 
             WHERE organization_id IN (select child_org_id from parent_child_organization where parent_org_id = ${child_organization_raw.id}));`
            );
            }

            DutyParticipant[] dutyParticipantsArray = [];
            check from DutyParticipant dutyParticipant in duty_participants
                do {
                    dutyParticipantsArray.push(dutyParticipant);
                };

            var updateResult = updateDutyParticipantsWorkRotation(dutyParticipantsArray);

            if (updateResult is error) {
                log:printError("Error update Rotation Cycle of duty participants: ", updateResult);
            } else {
                log:printInfo("Duty participants Rotation Cycle updated successfully");
            }

        };
}

isolated function updateDutyParticipantsWorkRotation(DutyParticipant[] dutyParticipantsArray) returns error? {

    stream<Activity, error?> dynamicDutyActivities;
    int?[] dynamicDutyActivitiesArray = [];

    dynamicDutyActivities = db_client->query(
                ` SELECT *
                FROM activity
                WHERE avinya_type_id = "91" AND description = "dynamic"
                ORDER BY id ASC ;`
            );

    check from Activity dutyActivities in dynamicDutyActivities
        do {
            dynamicDutyActivitiesArray.push(dutyActivities.id);
            io:println(dutyActivities.id);

        };

    foreach DutyParticipant activityObject in dutyParticipantsArray {

        //if (activityObject.role == "member") {

        int? currentIndex = dynamicDutyActivitiesArray.indexOf(activityObject.activity_id);
        int? nextIndex = (currentIndex + 1) % dynamicDutyActivitiesArray.length();

        if (currentIndex != null && nextIndex != null) {

            activityObject.activity_id = dynamicDutyActivitiesArray[nextIndex];

            int id = activityObject.id ?: 0;
            if (id == 0) {
                return error("Unable to update duty participant raw");
            }

            sql:ExecutionResult res = check db_client->execute(
                                `UPDATE duty_participant SET
                                activity_id = ${activityObject.activity_id}               
                                WHERE id = ${id};`
                            );

            if (res.affectedRowCount == sql:EXECUTION_FAILED) {
                return error("Execution failed.unable to update duty participant raw");
            }

        }
        //}
    }

}
