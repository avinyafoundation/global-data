import ballerina/graphql;
import ballerina/sql;

// @display {
//     label: "Global Data API",
//     id: "global-data"
// }
service graphql:Service /graphql on new graphql:Listener(4000) {
    resource function get geo() returns GeoData {
        return new ();
    }

    resource function get avinya_types() returns AvinyaTypeData[]|error {
        stream<AvinyaType, error?> avinyaTypes;
        lock {
            avinyaTypes = db_client->query(
                `SELECT *
                FROM avinya_db.avinya_type`
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
            `INSERT INTO avinya_db.avinya_type (
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

        return new(insert_id);
    }

    remote function update_avinya_type(AvinyaType avinya_type) returns AvinyaTypeData|error? {
        int id = avinya_type.id ?: 0;
        if (id == 0) {
            return error("Unable to update Avinya Type");
        }

        sql:ExecutionResult res = check db_client->execute(
            `UPDATE avinya_db.avinya_type SET
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
        
        return new(id);
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

    isolated resource function get prospect(string? email, int? phone) returns ProspectData|error? {
        return new (email, phone);
    }

    isolated resource function get applicant_consent(string? email, int? phone) returns ApplicantConsentData|error? {
        return new (email, phone);
    }

    isolated resource function get application(int person_id) returns ApplicationData|error? {
        return new (0, person_id);
    }

    isolated resource function get student_applicant(string? jwt_sub_id) returns PersonData|error? {
        AvinyaType avinya_type_raw = check db_client -> queryRow(
            `SELECT *
            FROM avinya_db.avinya_type
            WHERE global_type = "applicant" AND  foundation_type = "student";`
        );

        Person|error? applicantRaw = db_client -> queryRow(
            `SELECT *
            FROM avinya_db.person
            WHERE jwt_sub_id = ${jwt_sub_id} AND 
            avinya_type_id = ${avinya_type_raw.id};`
        );
        
        if(applicantRaw is Person) {
            return new ((), applicantRaw.id);
        }

        return error("Applicant does not exist for given sub id: " + (jwt_sub_id?:""));
        
    }

    remote function add_educator_applicant(Person person) returns PersonData|error? {

        AvinyaType avinya_type_raw = check db_client -> queryRow(
            `SELECT *
            FROM avinya_db.avinya_type
            WHERE global_type = "applicant" AND  foundation_type = "educator";`
        );

        Person|error? applicantRaw = db_client -> queryRow(
            `SELECT *
            FROM avinya_db.person
            WHERE (email = ${person.email}  OR
            phone = ${person.phone} OR 
            jwt_sub_id = ${person.jwt_sub_id}) AND 
            avinya_type_id = ${avinya_type_raw.id};`
        );
        
        if(applicantRaw is Person) {
            return error("Applicant already exists. The phone, email or the social login account you are using is already used by another applicant");
        }
        
        sql:ExecutionResult|error res = db_client->execute(
            `INSERT INTO avinya_db.person (
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

            return new((), insert_id); 
        } 
            
        return error("Error while inserting data", res);
        
    }

    remote function  add_student_applicant(Person person) returns PersonData|error? {

        AvinyaType avinya_type_raw = check db_client -> queryRow(
            `SELECT *
            FROM avinya_db.avinya_type
            WHERE global_type = "applicant" AND  foundation_type = "student";`
        );

        Person|error? applicantRaw = db_client -> queryRow(
            `SELECT *
            FROM avinya_db.person
            WHERE (email = ${person.email}  OR
            phone = ${person.phone} OR 
            jwt_sub_id = ${person.jwt_sub_id}) AND 
            avinya_type_id = ${avinya_type_raw.id};`
        );
        
        if(applicantRaw is Person) {
            return error("Applicant already exists. The phone, email or the social login account you are using is already used by another applicant");
        }
        
        sql:ExecutionResult|error res = db_client->execute(
            `INSERT INTO avinya_db.person (
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

            return new((), insert_id); 
        } 
            
        return error("Error while inserting data", res);
        
    }

    remote function  add_student_applicant_consent(ApplicantConsent applicantConsent) returns ApplicantConsentData|error? {
        
        ApplicantConsent|error? applicantConsentRaw = db_client -> queryRow(
            `SELECT *
            FROM avinya_db.applicant_consent
            WHERE (email = ${applicantConsent.email}  OR
            phone = ${applicantConsent.phone}) AND 
            active = TRUE;`
        );
        
        if(applicantConsentRaw is ApplicantConsent) {
            return error("Applicant already exists. The phone or the email you provided is already used by another applicant");
        }

        sql:ExecutionResult res = check db_client->execute(
            `INSERT INTO avinya_db.applicant_consent (
                name,
                date_of_birth,
                done_ol,
                ol_year,
                distance_to_school,
                phone,
                email,
                information_correct_consent,
                agree_terms_consent
            ) VALUES (
                ${applicantConsent.name},
                ${applicantConsent.date_of_birth},
                ${applicantConsent.done_ol},
                ${applicantConsent.ol_year},
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

        return new((), applicantConsent.phone);
    }

    remote function add_application(Application application) returns ApplicationData|error? {
        sql:ExecutionResult res = check db_client->execute(
            `INSERT INTO avinya_db.application (
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
            `INSERT INTO avinya_db.application_status (
                application_id
            ) VALUES (
                ${insert_id}
            );`
        ); // default status with for new application is "New" and is_terminal false


        return new(insert_id);
    }

    remote function  add_evaluations(Evaluation[] evaluations) returns int|error? {
        
        int count = 0;

        foreach Evaluation evaluation in evaluations {
            sql:ExecutionResult res = check db_client->execute(
                `INSERT INTO avinya_db.evaluation (
                    evaluatee_id,
                    evaluator_id,
                    evaluation_criteria_id,
                    response,
                    notes,
                    grade
                ) VALUES (
                    ${evaluation.evaluatee_id},
                    ${evaluation.evaluator_id},
                    ${evaluation.evaluation_criteria_id},
                    ${evaluation.response},
                    ${evaluation.notes},
                    ${evaluation.grade}
                );`
            );

            int|string? insert_id = res.lastInsertId;
            if !(insert_id is int) {
                return error("Unable to insert evaluation");
            } else {
                count += 1;
            }

            // Insert child and parent evaluation relationships
            int[] child_eval_ids = evaluation.child_evaluations ?: [];
            int[] parent_eval_ids = evaluation.parent_evaluations ?: [];

            foreach int child_idx in child_eval_ids {
                _ = check db_client->execute(
                    `INSERT INTO avinya_db.parent_child_evaluation (
                        child_evaluation_id,
                        parent_evaluation_id
                    ) VALUES (
                        ${child_idx}, ${insert_id}
                    );` 
                );
            }

            foreach int parent_idx in parent_eval_ids {
                _ = check db_client->execute(
                    `INSERT INTO avinya_db.parent_child_evaluation (
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

    remote function add_address(Address address) returns AddressData|error? {
        sql:ExecutionResult res = check db_client->execute(
            `INSERT INTO avinya_db.address (
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

        return new(insert_id);
    }

    remote function add_prospect(Prospect prospect) returns ProspectData|error? {
        Prospect|error? prospectRaw = db_client -> queryRow(
            `SELECT *
            FROM avinya_db.prospect
            WHERE (email = ${prospect.email}  OR
            phone = ${prospect.phone}) AND 
            active = TRUE;`
        );
        
        if(prospectRaw is Prospect) {
            return error("Prospect already exists. The phone or the email you provided is already used by another prospect");
        }
        
        sql:ExecutionResult res = check db_client->execute(
            `INSERT INTO avinya_db.prospect (
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

        return new(prospect.email, prospect.phone);
    }

    remote function add_organization(Organization org) returns OrganizationData|error? {
        sql:ExecutionResult res = check db_client->execute(
            `INSERT INTO avinya_db.organization (
                name_en,
                name_si,
                name_ta,
                address_id,
                phone
            ) VALUES (
                ${org.name_en},
                ${org.name_si},
                ${org.name_ta},
                ${org.address_id},
                ${org.phone}
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
                `INSERT INTO avinya_db.parent_child_organization (
                    child_org_id,
                    parent_org_id
                ) VALUES (
                    ${child_idx}, ${insert_id}
                );` 
            );
        }

        foreach int parent_idx in parent_eval_ids {
            _ = check db_client->execute(
                `INSERT INTO avinya_db.parent_child_organization (
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
        sql:ExecutionResult res = check db_client->execute(
            `INSERT INTO avinya_db.activity_participant_attendance (
                activity_instance_id,
                person_id,
                sign_in_time,
                sign_out_time
            ) VALUES (
                ${attendance.activity_instance_id},
                ${attendance.person_id},
                ${attendance.sign_in_time},
                ${attendance.sign_out_time}
            );`
        );

        int|string? insert_id = res.lastInsertId;
        if !(insert_id is int) {
            return error("Unable to insert attendance");
        }

        return new(insert_id);
    }

    remote function  add_empower_parent(Person person) returns PersonData|error? {

        AvinyaType avinya_type_raw = check db_client -> queryRow(
            `SELECT *
            FROM avinya_db.avinya_type
            WHERE global_type = "customer" AND  foundation_type = "parent";`
        );

        Person|error? applicantRaw = db_client -> queryRow(
            `SELECT *
            FROM avinya_db.person
            WHERE (email = ${person.email}  OR
            phone = ${person.phone} OR
            jwt_sub_id = ${person.jwt_sub_id}) AND 
            avinya_type_id = ${avinya_type_raw.id};`
        );
        
        if(applicantRaw is Person) {
            return error("Parent already exists. The phone, email or the social login account you are using is already used by another parent");
        }
        
        sql:ExecutionResult res = check db_client->execute(
            `INSERT INTO avinya_db.person (
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
                `INSERT INTO avinya_db.parent_child_student (
                    child_student_id,
                    parent_student_id
                ) VALUES (
                    ${child_idx}, ${insert_id}
                );` 
            );
        }

        foreach int parent_idx in parent_student_ids {
            _ = check db_client->execute(
                `INSERT INTO avinya_db.parent_child_student (
                    child_student_id,
                    parent_student_id
                ) VALUES (
                    ${insert_id}, ${parent_idx}
                );` 
            );
        }

        return new ((), insert_id);
        
    }
 
    remote function  update_application_status(string applicationStatus, int applicationId) returns ApplicationStatusData|error? {
        
        ApplicationStatus|error? appStatusRaw = db_client -> queryRow(
            `SELECT *
            FROM avinya_db.application_status
            WHERE(application_id = ${applicationId});`

        );

        if !(appStatusRaw is ApplicationStatus){
            return error("Application status does not exist");
        }

        // add new application_status
        sql:ExecutionResult|error res = db_client->execute(
            `UPDATE avinya_db.application_status
            SET status = ${applicationStatus}
            WHERE(application_id = ${applicationId});`
        );

        if (res is sql:ExecutionResult) {
            
            int? insert_count = res.affectedRowCount;
            if !(insert_count is int) {
                return error("Unable to update application status");
            }

            return new((), appStatusRaw); 
        } 
            
        return error("Error while inserting data", res);

    }

    remote function update_person_avinya_type(int personId, int newAvinyaId, string transitionDate) returns PersonData|error?{
        Person|error? personRaw = db_client -> queryRow(
            `SELECT *
            FROM avinya_db.person
            WHERE (id = ${personId});`
        );

        if !(personRaw is Person){
            return error("Person does not exist");
        }

        // add to person_avinya_type_transition_history
        sql:ExecutionResult|error? resAdd = db_client -> execute(
            `INSERT INTO avinya_db.person_avinya_type_transition_history(
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
        sql:ExecutionResult|error? resUpdate = db_client -> execute(
            `UPDATE avinya_db.person
            SET avinya_type_id = ${newAvinyaId}
            WHERE(id = ${personId});`
        );

        if (resUpdate is sql:ExecutionResult) {
            
            int? insert_count = resUpdate.affectedRowCount;
            if !(insert_count is int) {
                return error("Unable to update person's avinya type");
            }
        } 
        else{
            return error("Error while updating data", resUpdate); 
        } 

        if (resAdd is sql:ExecutionResult) {
            
            int|string? insert_id = resAdd.lastInsertId;
            if !(insert_id is int) {
                return error("Unable to insert person_avinya_type_transition_history");
            }

            return new((), insert_id); 
        } 
            
        return error("Error while inserting data", resAdd);
               
    }

    remote function add_activity(Activity activity) returns ActivityData|error?{
        Activity|error? activityRaw = db_client -> queryRow(
            `SELECT *
            FROM avinya_db.activity
            WHERE (name = ${activity.name} AND
            avinya_type_id = ${activity.avinya_type_id});`
        );

        if(activityRaw is Activity) {
            return error("Activity already exists. The name and avinya_type_id you are using is already used by another activity");
        }

        sql:ExecutionResult res = check db_client->execute(
            `INSERT INTO avinya_db.activity (
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
                `INSERT INTO avinya_db.parent_child_activity (
                    child_activity_id,
                    parent_activity_id
                ) VALUES (
                    ${child_idx}, ${insert_id}
                );` 
            );
        }

        foreach int parent_idx in parent_activities_ids {
            _ = check db_client->execute(
                `INSERT INTO avinya_db.parent_child_activity (
                    child_activity_id,
                    parent_activity_id
                ) VALUES (
                    ${insert_id}, ${parent_idx}
                );` 
            );
        }

        return new ((), insert_id);
        
    }

    remote function add_activity_sequence_plan(ActivitySequencePlan activitySequencePlan) returns ActivitySequencePlanData|error?{
        sql:ExecutionResult res = check db_client->execute(
            `INSERT INTO avinya_db.activity_sequence_plan (
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

    remote function add_activity_instance(ActivityInstance activityInstance) returns ActivityInstanceData|error?{
        sql:ExecutionResult res = check db_client->execute(
            `INSERT INTO avinya_db.activity_instance (
                activity_id,
                name,
                place_id,
                daily_sequence,
                weekly_sequence,
                monthly_sequence
            ) VALUES (
                ${activityInstance.activity_id},
                ${activityInstance.name},
                ${activityInstance.place_id},
                ${activityInstance.daily_sequence},
                ${activityInstance.weekly_sequence},
                ${activityInstance.monthly_sequence}
            );`
        );

        int|string? insert_id = res.lastInsertId;
        if !(insert_id is int) {
            return error("Unable to insert activity instance");
        }

        return new ((), insert_id);
    }

    remote function add_activity_participant(ActivityParticipant activityParticipant) returns ActivityParticipantData|error?{
        ActivityParticipant|error? activityParticipantRaw = db_client -> queryRow(
            `SELECT *
            FROM avinya_db.activity_participant
            WHERE (activity_instance_id = ${activityParticipant.activity_instance_id} AND
            person_id = ${activityParticipant.person_id});`
        );

        if(activityParticipantRaw is ActivityParticipant) {
            return error("Activity participant already exists. The activity_instance_id and person_id you are using is already used by another activity participant");
        }
        
        sql:ExecutionResult res = check db_client->execute(
            `INSERT INTO avinya_db.activity_participant (
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

    remote function update_attendance(int attendanceId, string sign_out_time) returns ActivityParticipantAttendanceData|error?{
        ActivityParticipantAttendance|error? participantAttendanceRaw = db_client -> queryRow(
            `SELECT *
            FROM avinya_db.activity_participant_attendance
            WHERE (id = ${attendanceId});`
        );

        if !(participantAttendanceRaw is ActivityParticipantAttendance){
            return error("Activity participant does not exist");
        }

        // set sign_out_time
        sql:ExecutionResult|error res = db_client->execute(
            `UPDATE avinya_db.activity_participant_attendance
            SET sign_out_time = ${sign_out_time}
            WHERE(id = ${attendanceId});`
        );

        if (res is sql:ExecutionResult) {
            
            int? insert_count = res.affectedRowCount;
            if !(insert_count is int) {
                return error("Unable to update attendance sign out time");
            }

            return new((), participantAttendanceRaw); 
        } 
            
        return error("Error while inserting data", res);
    }

    remote function add_vacancy(Vacancy vacancy) returns VacancyData|error?{
        sql:ExecutionResult res = check db_client->execute(
            `INSERT INTO avinya_db.vacancy (
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

    remote function add_person(Person person, int? avinya_type_id) returns PersonData|error?{
        AvinyaType avinya_type_raw;
        
        if(avinya_type_id != null) {
                avinya_type_raw = check db_client -> queryRow(
                    `SELECT *
                    FROM avinya_db.avinya_type
                    WHERE id = ${avinya_type_id};`
                );
        }else {
            avinya_type_raw = check db_client -> queryRow(
                `SELECT *
                FROM avinya_db.avinya_type
                WHERE global_type = "unassigned" AND  foundation_type = "unassigned";`
            );
        }

        Person|error? personRaw = db_client -> queryRow(
            `SELECT *
            FROM avinya_db.person
            WHERE (email = ${person.email}  OR
            phone = ${person.phone} OR
            jwt_sub_id = ${person.jwt_sub_id}) AND 
            avinya_type_id = ${avinya_type_raw.id};`
        ); 
        
        if(personRaw is Person) {
            return error("Person already exists. The phone, email or the social login account you are using is already used by another person");
        }
        
        sql:ExecutionResult res = check db_client->execute(
            `INSERT INTO avinya_db.person (
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
            return error("Unable to insert person");
        }

        // Insert child and parent relationships
        int[] child_student_ids = person.child_student ?: [];
        int[] parent_student_ids = person.parent_student ?: [];

        foreach int child_idx in child_student_ids {
            _ = check db_client->execute(
                `INSERT INTO avinya_db.parent_child_student (
                    child_student_id,
                    parent_student_id
                ) VALUES (
                    ${child_idx}, ${insert_id}
                );` 
            );
        }

        foreach int parent_idx in parent_student_ids {
            _ = check db_client->execute(
                `INSERT INTO avinya_db.parent_child_student (
                    child_student_id,
                    parent_student_id
                ) VALUES (
                    ${insert_id}, ${parent_idx}
                );` 
            );
        } 

        return new ((), insert_id);  

    }

    isolated resource function get asset(int id) returns AssetData|error? {
        return new AssetData(id);
    }

    remote function add_asset(Asset asset) returns AssetData|error?{
        Asset|error? assetRaw = db_client -> queryRow(
            `SELECT *
            FROM avinya_db.asset
            WHERE name = ${asset.name} AND
            serial_number = ${asset.serial_number};`
        );

        if(assetRaw is Asset) {
            return error("Asset already exists. The name or the serial number you are using is already used by another asset");
        }

        sql:ExecutionResult res = check db_client->execute(
            `INSERT INTO avinya_db.asset (
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
    
    remote function  update_asset(Asset asset) returns AssetData|error? {
        int id = asset.id ?: 0;
        if (id == 0) {
            return error("Unable to update Asset Data");
        }

        Asset|error? assetRaw = db_client -> queryRow(
            `SELECT *
            FROM avinya_db.asset
            WHERE name = ${asset.name} AND
            serial_number = ${asset.serial_number};`

        );

        if !(assetRaw is Asset){
            return error("Asset Data does not exist");
        }

        sql:ExecutionResult|error res = db_client->execute(
            `UPDATE avinya_db.asset SET
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
            return new(id);
        } else {
            return error("Unable to update Asset Data");
        }
    }

    isolated resource function get supplier(int id) returns SupplierData|error? {
        return new SupplierData(id);
    }

    remote function add_supplier(Supplier supplier) returns SupplierData|error?{
        Supplier|error? supplierRaw = db_client -> queryRow(
            `SELECT *
            FROM avinya_db.supplier
            WHERE name = ${supplier.name};`
        );

        if(supplierRaw is Supplier) {
            return error("Supplier already exists. The name you are using is already used by another supplier");
        }

        sql:ExecutionResult res = check db_client->execute(
            `INSERT INTO avinya_db.supplier (
                name,
                phone,
                email,
                address_id,
                description,
            ) VALUES (
                ${supplier.name},
                ${supplier.phone},
                ${supplier.email},
                ${supplier.address_id},
                ${supplier.description},
            );`
        );

        int|string? insert_id = res.lastInsertId;
        if !(insert_id is int) {
            return error("Unable to insert supplier");
        }

        return new (insert_id);
    }

    remote function  update_supplier(Supplier supplier) returns SupplierData|error? {
        int id = supplier.id ?: 0;
        if (id == 0) {
            return error("Unable to update Supplier Data");
        }

        Supplier|error? supplierRaw = db_client -> queryRow(
            `SELECT *
            FROM avinya_db.supplier
            WHERE name = ${supplier.name};`
        );

        if !(supplierRaw is Supplier){
            return error("Supplier Data does not exist");
        }

        sql:ExecutionResult|error res = db_client->execute(
            `UPDATE avinya_db.supplier SET
                name = ${supplier.name},
                phone = ${supplier.phone},
                email = ${supplier.email},
                address_id = ${supplier.address_id},
                description = ${supplier.description},
            WHERE id = ${id};`
        );

        if (res is sql:ExecutionResult) {
            return new(id);
        } else {
            return error("Unable to update Supplier Data");
        }
    }

    isolated resource function get consumable(int id) returns ConsumableData|error? {
        return new ConsumableData(id);
    }

    remote function add_consumable(Consumable consumable) returns ConsumableData|error?{
        Consumable|error? consumableRaw = db_client -> queryRow(
            `SELECT *
            FROM avinya_db.consumable
            WHERE name = ${consumable.name} AND
            avinya_type_id = ${consumable.avinya_type_id};`
        );

        if(consumableRaw is Consumable) {
            return error("Consumable already exists. The name you are using is already used by another consumable");
        }

        sql:ExecutionResult res = check db_client->execute(
            `INSERT INTO avinya_db.consumable (
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

    remote function update_consumable(Consumable consumable) returns ConsumableData|error? {
        int id = consumable.id ?: 0;
        if (id == 0) {
            return error("Unable to update Consumable Data");
        }

        Consumable|error? consumableRaw = db_client -> queryRow(
            `SELECT *
            FROM avinya_db.consumable
            WHERE name = ${consumable.name} AND
            avinya_type_id = ${consumable.avinya_type_id};`
        );

        if !(consumableRaw is Consumable){
            return error("Consumable Data does not exist");
        }

        sql:ExecutionResult|error res = db_client->execute(
            `UPDATE avinya_db.consumable SET
                name = ${consumable.name},
                description = ${consumable.description},
                manufacturer = ${consumable.manufacturer},
                model = ${consumable.model},
                serial_number = ${consumable.serial_number},
                avinya_type_id = ${consumable.avinya_type_id}
            WHERE id = ${id};`
        );

        if (res is sql:ExecutionResult) {
            return new(id);
        } else {
            return error("Unable to update Consumable Data");
        }
    }

    isolated resource function get resource_property(int id) returns ResourcePropertyData|error? {
        return new ResourcePropertyData(id);
    }

    remote function add_resource_property(ResourceProperty resourceProperty) returns ResourcePropertyData|error?{
        ResourceProperty|error? resourcePropertyRaw = db_client -> queryRow(
            `SELECT *
            FROM avinya_db.resource_property
            WHERE property =  ${resourceProperty.property} AND
            asset_id = ${resourceProperty.asset_id};`
        );

        if(resourcePropertyRaw is ResourceProperty) {
            return error("Resource Property already exists. The name you are using is already used by another resource property");
        }

        sql:ExecutionResult res = check db_client->execute(
            `INSERT INTO avinya_db.resource_property (
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

        ResourceProperty|error? resourcePropertyRaw = db_client -> queryRow(
            `SELECT *
            FROM avinya_db.resource_property
            WHERE property =  ${resourceProperty.property} AND
            asset_id = ${resourceProperty.asset_id};`
        );

        if !(resourcePropertyRaw is ResourceProperty){
            return error("Resource Property Data does not exist");
        }

        sql:ExecutionResult|error res = db_client->execute(
            `UPDATE avinya_db.resource_property SET
                property = ${resourceProperty.property},
                value = ${resourceProperty.value},
                consumable_id = ${resourceProperty.consumable_id},
                asset_id = ${resourceProperty.asset_id}
            WHERE id = ${id};`
        );

        if (res is sql:ExecutionResult) {
            return new(id);
        } else {
            return error("Unable to update Resource Property Data");
        }
    }

    isolated resource function get supply(int id) returns SupplyData|error? {
        return new SupplyData(id);
    }

    remote function add_supply(Supply supply) returns SupplyData|error?{
        Supply|error? supplyRaw = db_client -> queryRow(
            `SELECT *
            FROM avinya_db.supply
            WHERE asset_id = ${supply.asset_id} AND
            supplier_id = ${supply.supplier_id};`
        );

        if(supplyRaw is Supply) {
            return error("Supply already exists. The name you are using is already used by another supply");
        }

        sql:ExecutionResult res = check db_client->execute(
            `INSERT INTO avinya_db.supply (
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

        Supply|error? supplyRaw = db_client -> queryRow(
            `SELECT *
            FROM avinya_db.supply
            WHERE asset_id = ${supply.asset_id} AND
            supplier_id = ${supply.supplier_id};`
        );

        if !(supplyRaw is Supply){
            return error("Supply Data does not exist");
        }

        sql:ExecutionResult|error res = db_client->execute(
            `UPDATE avinya_db.supply SET
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
            return new(id);
        } else {
            return error("Unable to update Supply Data");
        }
    }

    isolated resource function get resource_allocation(int id) returns ResourceAllocationData|error? {
        return new ResourceAllocationData(id);
    }

    remote function add_resource_allocation(ResourceAllocation resourceAllocation) returns ResourceAllocationData|error?{
        ResourceAllocation|error? resourceAllocationRaw = db_client -> queryRow(
            `SELECT *
            FROM avinya_db.resource_allocation
            WHERE consumable_id = ${resourceAllocation.consumable_id} AND
            person_id = ${resourceAllocation.person_id};`
        );

        if(resourceAllocationRaw is ResourceAllocation) {
            return error("Resource Allocation already exists. The name you are using is already used by another resource allocation");
        }

        sql:ExecutionResult res = check db_client->execute(
            `INSERT INTO avinya_db.resource_allocation (
                asset_id,
                consumable_id,
                organization_id,
                person_id,
                quantity,
                start_date,
                end_date
            ) VALUES (
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

        ResourceAllocation|error? resourceAllocationRaw = db_client -> queryRow(
            `SELECT *
            FROM avinya_db.resource_allocation
            WHERE consumable_id = ${resourceAllocation.consumable_id} AND
            person_id = ${resourceAllocation.person_id};`
        );

        if !(resourceAllocationRaw is ResourceAllocation){
            return error("Resource Allocation Data does not exist");
        }

        sql:ExecutionResult|error res = db_client->execute(
            `UPDATE avinya_db.resource_allocation SET
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
            return new(id);
        } else {
            return error("Unable to update resource allocation Data");
        }
    }

    isolated resource function get inventory(int id) returns InventoryData|error? {
        return new InventoryData(id);
    }

    remote function add_inventory(Inventory inventory) returns InventoryData|error?{
        Inventory|error? inventoryRaw = db_client -> queryRow(
            `SELECT *
            FROM avinya_db.inventory
            WHERE asset_id = ${inventory.asset_id} AND
            consumable_id = ${inventory.consumable_id};`
        );

        if(inventoryRaw is Inventory) {
            return error("Inventory already exists. The name you are using is already used by another inventory");
        }

        sql:ExecutionResult res = check db_client->execute(
            `INSERT INTO avinya_db.inventory (
                asset_id,
                consumable_id,
                organization_id,
                person_id,
                quantity,
                quantity_in,
                quantity_out,
            ) VALUES (
                ${inventory.asset_id},
                ${inventory.consumable_id},
                ${inventory.organization_id},
                ${inventory.person_id},
                ${inventory.quantity},
                ${inventory.quantity_in},
                ${inventory.quantity_out},
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

        Inventory|error? inventoryRaw = db_client -> queryRow(
            `SELECT *
            FROM avinya_db.inventory
            WHERE asset_id = ${inventory.asset_id} AND
            consumable_id = ${inventory.consumable_id};`
        );

        if !(inventoryRaw is Inventory){
            return error("Inventory Data does not exist");
        }

        sql:ExecutionResult|error res = db_client->execute(
            `UPDATE avinya_db.inventory SET
                asset_id = ${inventory.asset_id},
                consumable_id = ${inventory.consumable_id},
                organization_id = ${inventory.organization_id},
                person_id = ${inventory.person_id},
                quantity = ${inventory.quantity},
                quantity_in = ${inventory.quantity_in},
                quantity_out = ${inventory.quantity_out},
            WHERE id = ${id};`
        );

        if (res is sql:ExecutionResult) {
            return new(id);
        } else {
            return error("Unable to update inventory Data");
        }
    }
}
