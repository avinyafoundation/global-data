import ballerinax/googleapis.drive;



public isolated service class PersonData {
    private Person person;

    isolated function init(string? name = null, int? person_id = 0, Person? person = null) returns error? {
        if(person != null) { // if person is provided, then use that and do not load from DB
            self.person = person.cloneReadOnly();
            return;
        }

        string _name = "%" + (name ?: "") + "%";
        int id = person_id ?: 0;

        Person person_raw;
        if(id > 0) { // organization_id provided, give precedance to that
            person_raw = check db_client -> queryRow(
            `SELECT *
            FROM person
            WHERE
                id = ${id};`);
        } else 
        {
            person_raw = check db_client -> queryRow(
            `SELECT *
            FROM person
            WHERE
                preferred_name LIKE ${_name};`);
        }
        
        self.person = person_raw.cloneReadOnly();
    }

    isolated resource function get id() returns int? {
        lock {
                return self.person.id;
        }
    }

    isolated resource function get preferred_name() returns string?{
        lock {
                return self.person.preferred_name;
        }
    }

    isolated resource function get full_name() returns string?{
        lock {
            return self.person.full_name;
        }
    }

    isolated resource function get date_of_birth() returns string?{
        lock {
            return self.person.date_of_birth;
        }
    }

    isolated resource function get created() returns string?{
        lock {
            return self.person.created;
        }
    }

    isolated resource function get updated() returns string?{
        lock {
            return self.person.updated;
        }
    }

    isolated resource function get sex() returns string?{
        lock {
            return self.person.sex;
        }
    }

    isolated resource function get asgardeo_id() returns string?{
        lock {
            return self.person.asgardeo_id;
        }
    }

    isolated resource function get jwt_sub_id() returns string?{
        lock {
            return self.person.jwt_sub_id;
        }
    }

    isolated resource function get jwt_email() returns string?{
        lock {
            return self.person.jwt_email;
        }
    }

    isolated resource function get permanent_address() returns AddressData|error? {
        int id = 0;
        lock {
            id = self.person.permanent_address_id ?: 0;
            if( id == 0) {
                return null; // no point in querying if address id is null
            } 
        }
        
        return new AddressData(id);
    }

    isolated resource function get mailing_address() returns AddressData|error? {
        int id = 0;
        lock {
            id = self.person.mailing_address_id ?: 0;
            if( id == 0) {
                return null; // no point in querying if address id is null
            } 
        }
        
        return new AddressData(id);
    }

    isolated resource function get phone() returns int? {
        lock {
            return self.person.phone;
        }
    }

    isolated resource function get organization() returns OrganizationData|error? {
        int id = 0;
        lock {
            id = self.person.organization_id ?: 0;
            if( id == 0) {
                return null; // no point in querying if address id is null
            } 
        }

        return new OrganizationData((), id);
    }

    isolated resource function get avinya_type() returns AvinyaTypeData|error? {
        int id = 0;
        lock {
            id = self.person.avinya_type_id ?: 0;
            if( id == 0) {
                return null; // no point in querying if address id is null
            } 
        }
        
        return new AvinyaTypeData(id);
    }

    isolated resource function get avinya_type_id() returns int? {
        lock {
            return self.person.avinya_type_id;
        }
    }

    isolated resource function get notes() returns string?{
        lock {
            return self.person.notes;
        }
    }

    isolated resource function get nic_no() returns string?{
        lock {
            return self.person.nic_no;
        }
    }

    isolated resource function get passport_no() returns string?{
        lock {
            return self.person.passport_no;
        }
    }

    isolated resource function get id_no() returns string?{
        lock {
            return self.person.id_no;
        }
    }

    isolated resource function get email() returns string?{
        lock {
            return self.person.email;
        }
    }

    isolated resource function get child_students() returns PersonData[]|error? {
        // Get list of child organizations
        stream<ParentChildStudent, error?> child_student_ids;
        lock {
            child_student_ids = db_client->query(
                `SELECT *
                FROM parent_child_student
                WHERE parent_student_id = ${self.person.id}`
            );
        }

        PersonData[] child_students = [];

        check from ParentChildStudent pcs in child_student_ids
            do {
                PersonData|error candidate_person = new PersonData((), pcs.child_student_id);
                if !(candidate_person is error) {
                    child_students.push(candidate_person);
                }
            };
        check child_student_ids.close();
        return child_students;
    }

    isolated resource function get parent_students() returns PersonData[]|error? {
        // Get list of child organizations
        stream<ParentChildStudent, error?> parent_student_ids;
        lock {
            parent_student_ids = db_client->query(
                `SELECT *
                FROM parent_child_student
                WHERE child_student_id = ${self.person.id}`
            );
        }

        PersonData[] parent_students = [];

        check from ParentChildStudent pcs in parent_student_ids
            do {
                PersonData|error candidate_person = new PersonData((), pcs.parent_student_id);
                if !(candidate_person is error) {
                    parent_students.push(candidate_person);
                }
            };
        check parent_student_ids.close();
        return parent_students;
    }

    isolated resource function get street_address() returns string?{
        lock {
            return self.person.street_address;
        }
    }

    isolated resource function get digital_id() returns string?{
        lock {
            return self.person.digital_id;
        }
    }

    isolated resource function get avinya_phone() returns int?{
        lock {
            return self.person.avinya_phone;
        }
    }

    isolated resource function get bank_name() returns string?{
        lock {
            return self.person.bank_name;
        }
    }

    isolated resource function get bank_branch() returns string?{
        lock {
            return self.person.bank_branch;
        }
    }

    isolated resource function get bank_account_number() returns string?{
        lock {
            return self.person.bank_account_number;
        }
    }

    isolated resource function get bank_account_name() returns string?{
        lock {
            return self.person.bank_account_name;
        }
    }

    isolated resource function get academy_org_id() returns int?{
        lock {
            return self.person.academy_org_id;
        }
    }

    isolated resource function get organization_id() returns int?{
        lock {
            return self.person.organization_id;
        }
    }

    isolated resource function get parent_organization_id() returns int?{
        lock {
            return self.person.parent_organization_id;
        }
    }
    isolated resource function get branch_code() returns string?{
        lock {
            return self.person.branch_code;
        }
    }


    isolated resource function get current_job() returns string? {
        lock {
            return self.person.current_job;
        }
    }

    isolated resource function get created_by() returns int? {
        lock {
                return self.person.created_by;
        }
    }

    isolated resource function get updated_by() returns int? {
        lock {
            return self.person.updated_by;
        }
    }

    isolated resource function get documents_id() returns int? {
        lock {
                return self.person.documents_id;
        }
    }

    isolated resource function get alumni_id() returns int? {
        lock {
            return self.person.alumni_id;
        }
    }

    isolated resource function get alumni() returns AlumniData|error? {
        int id = 0;
        lock {
            id = self.person.alumni_id ?: 0;
            if (id == 0) {
                return null; // no point in querying if alumni id is null
            }
        }

        return new AlumniData(id);
    }

    isolated resource function get is_graduated() returns boolean? {
        lock {
            return self.person.is_graduated;
        }
    }

    isolated resource function get alumni_education_qualifications() returns AlumniEducationQualificationData[]|error? {
        // Get list of alumni education qualifications
        stream<AlumniEducationQualification, error?> alumni_education_qualification_ids;
        lock {
            alumni_education_qualification_ids = db_client->query(
                `SELECT id
                FROM alumni_education_qualifications
                WHERE person_id = ${self.person.id}`
            );
        }

        AlumniEducationQualificationData[] alumni_education_qualifications = [];

        check from AlumniEducationQualification aeq in alumni_education_qualification_ids
            do {
                AlumniEducationQualificationData|error alumni_education_qualification = new AlumniEducationQualificationData(aeq.id);
                if !(alumni_education_qualification is error) {
                    alumni_education_qualifications.push(alumni_education_qualification);
                }
            };
        check alumni_education_qualification_ids.close();
        return alumni_education_qualifications;
    }

    isolated resource function get alumni_work_experience() returns AlumniWorkExperienceData[]|error? {
        // Get list of alumni work experience
        stream<AlumniWorkExperience, error?> alumni_work_experience_ids;
        lock {
            alumni_work_experience_ids = db_client->query(
                `SELECT id
                FROM alumni_work_experience
                WHERE person_id = ${self.person.id}`
            );
        }

        AlumniWorkExperienceData[] alumni_work_experiences = [];

        check from AlumniWorkExperience awe in alumni_work_experience_ids
            do {
                AlumniWorkExperienceData|error alumni_work_experience = new AlumniWorkExperienceData(awe.id);
                if !(alumni_work_experience is error) {
                    alumni_work_experiences.push(alumni_work_experience);
                }
            };
        check alumni_work_experience_ids.close();
        return alumni_work_experiences;
    }

    isolated resource function get profile_picture() returns PersonProfilePictureData|error?{

        drive:Client driveClient = check getDriveClient();


        string? profilePictureDriveId="";
        PersonProfilePicture|error personProfilePictureRaw;
        PersonProfilePicture emptyPersonProfilePicture = {
            id: 0,
            person_id: 0,
            profile_picture_drive_id: (),
            picture: (),
            nic_no: (),
            uploaded_by: (),
            created: (),
            updated: ()
        };

       lock{
            //Get the profile picture of user
            personProfilePictureRaw = db_client->queryRow(
                                                `SELECT *
                                                FROM person_profile_pictures
                                                WHERE person_id = ${self.person.id};`
                                        );
       }
        
        if(personProfilePictureRaw is PersonProfilePicture){
            profilePictureDriveId = personProfilePictureRaw.profile_picture_drive_id ?: "";
            PersonProfilePicture|error person_profile_picture = getProfilePicture(driveClient, profilePictureDriveId.toString());

            if (person_profile_picture is PersonProfilePicture) {
                person_profile_picture.id = personProfilePictureRaw.id;
                PersonProfilePictureData|error personProfilePictureData = new PersonProfilePictureData(0, 0, person_profile_picture);
                if !(personProfilePictureData is error) {
                    return personProfilePictureData;
                }
            } else {
                return error(person_profile_picture.message());
            }

        }else{
            PersonProfilePictureData|error emptyPersonProfilePictureData = new PersonProfilePictureData(0,0,emptyPersonProfilePicture);
            if !(emptyPersonProfilePictureData is error) {
                return emptyPersonProfilePictureData;
            }
        }
        return error("Failed to retrieve profile picture data.");
    }

    isolated resource function get profile_picture_folder_id() returns string? {
        lock {
            return self.person.profile_picture_folder_id;
        }
    }
}
