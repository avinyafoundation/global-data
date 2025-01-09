import ballerinax/googleapis.drive;
import ballerina/mime;


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

    isolated resource function get document_list() returns DocumentsData[]|error? {
        int id = 0;
        drive:Client driveClient = check getDriveClient();
        DocumentsData[] documents=[];
        UserDocument[] documentList=[];
        UserDocument user_document_list_raw;
        
        lock {
            
            id = self.person.documents_id ?: 0;
            if (id == 0) {
                return null; // no point in querying if document id is null
            }

            user_document_list_raw = check db_client->queryRow(
                                    `SELECT *
                                    FROM user_documents
                                    WHERE
                                        id = ${id};`);
           }
        
        string? nic_front_id = user_document_list_raw.nic_front_id;
        string? nic_back_id = user_document_list_raw.nic_back_id;
        string? birth_certificate_front_id = user_document_list_raw.birth_certificate_front_id;
        string? birth_certificate_back_id = user_document_list_raw.birth_certificate_back_id;
        string? ol_certificate_id = user_document_list_raw.ol_certificate_id;
        string? al_certificate_id = user_document_list_raw.al_certificate_id;
        string? additional_certificate_01_id = user_document_list_raw.additional_certificate_01_id;
        string? additional_certificate_02_id = user_document_list_raw.additional_certificate_02_id;
        string? additional_certificate_03_id = user_document_list_raw.additional_certificate_03_id;
        string? additional_certificate_04_id = user_document_list_raw.additional_certificate_04_id;
        string? additional_certificate_05_id = user_document_list_raw.additional_certificate_05_id;


        if nic_front_id is string {
                UserDocument|error nic_front_document = getDocument(driveClient,nic_front_id,"nicFront");
                if(nic_front_document is UserDocument){
                  documentList.push(nic_front_document);
                }else{
                    return error(nic_front_document.message());
                }
        }
        // else {
        //     return error("Nic front document doesn't exist.Skipping file retrieval.");
        // }

        if nic_back_id is string {
                UserDocument|error nic_back_document = getDocument(driveClient,nic_back_id,"nicBack");
                if(nic_back_document is UserDocument){
                  documentList.push(nic_back_document);
                }else{
                    return error(nic_back_document.message());
                }
        }
        // else {
        //     return error("Nic back document doesn't exist.Skipping file retrieval.");
        // }

        if birth_certificate_front_id is string {
                UserDocument|error birth_certificate_front_document = getDocument(driveClient,birth_certificate_front_id,"birthCertificateFront");
                if(birth_certificate_front_document is UserDocument){
                  documentList.push(birth_certificate_front_document);
                }else{
                    return error(birth_certificate_front_document.message());
                }
        }
        // else {
        //     return error("Birth Certificate front document doesn't exist.Skipping file retrieval.");
        // }

        if birth_certificate_back_id is string {
                UserDocument|error birth_certificate_back_document = getDocument(driveClient,birth_certificate_back_id,"birthCertificateBack");
                if(birth_certificate_back_document is UserDocument){
                  documentList.push(birth_certificate_back_document);
                }else{
                    return error(birth_certificate_back_document.message());
                }
        }
        // else {
        //     return error("Birth Certificate back document doesn't exist.Skipping file retrieval.");
        // }

        if ol_certificate_id is string {
                UserDocument|error ol_document = getDocument(driveClient,ol_certificate_id,"olDocument");
                if(ol_document is UserDocument){
                  documentList.push(ol_document);
                }else{
                    return error(ol_document.message());
                }
        }
        // else {
        //     return error("OL document doesn't exist.Skipping file retrieval.");
        // }

        if al_certificate_id is string {
                UserDocument|error al_document = getDocument(driveClient,al_certificate_id,"alDocument");
                if(al_document is UserDocument){
                  documentList.push(al_document);
                }else{
                    return error(al_document.message());
                }
        }
        // else {
        //     return error("AL document doesn't exist.Skipping file retrieval.");
        // }

        if additional_certificate_01_id is string {
                UserDocument|error additional_certificate_01_document = getDocument(driveClient,additional_certificate_01_id,"additionalCertificate01");
                if(additional_certificate_01_document is UserDocument){
                  documentList.push(additional_certificate_01_document);
                }else{
                    return error(additional_certificate_01_document.message());
                }
        }
        // else {
        //     return error("Additional Certificate 01 doesn't exist.Skipping file retrieval.");
        // }

        if additional_certificate_02_id is string {
                UserDocument|error additional_certificate_02_document = getDocument(driveClient,additional_certificate_02_id,"additionalCertificate02");
                if(additional_certificate_02_document is UserDocument){
                  documentList.push(additional_certificate_02_document);
                }else{
                    return error(additional_certificate_02_document.message());
                }
        }
        // else {
        //     return error("Additional Certificate 02 doesn't exist.Skipping file retrieval.");
        // }

        if additional_certificate_03_id is string {
                UserDocument|error additional_certificate_03_document = getDocument(driveClient,additional_certificate_03_id,"additionalCertificate03");
                if(additional_certificate_03_document is UserDocument){
                  documentList.push(additional_certificate_03_document);
                }else{
                    return error(additional_certificate_03_document.message());
                }
        }
        // else {
        //     return error("Additional Certificate 03 doesn't exist.Skipping file retrieval.");
        // }

        if additional_certificate_04_id is string {
                UserDocument|error additional_certificate_04_document = getDocument(driveClient,additional_certificate_04_id,"additionalCertificate04");
                if(additional_certificate_04_document is UserDocument){
                  documentList.push(additional_certificate_04_document);
                }else{
                    return error(additional_certificate_04_document.message());
                }
        }
        // else {
        //     return error("Additional Certificate 04 doesn't exist.Skipping file retrieval.");
        // }

        if additional_certificate_05_id is string {
                UserDocument|error additional_certificate_05_document = getDocument(driveClient,additional_certificate_05_id,"additionalCertificate05");
                if(additional_certificate_05_document is UserDocument){
                  documentList.push(additional_certificate_05_document);
                }else{
                    return error(additional_certificate_05_document.message());
                }
        }
        // else {
        //     return error("Additional Certificate 05 doesn't exist.Skipping file retrieval.");
        // }

        
        from UserDocument user_document_record in documentList
            do {
                DocumentsData|error documentData = new DocumentsData(0,user_document_record);
                if !(documentData is error) {
                    documents.push(documentData);
                }
            };

        return documents;
    }

}

isolated  function getDocument(drive:Client driveClient,string id,string document_name) returns UserDocument|error{

    UserDocument user_document={
                id:(),
                additional_certificate_01_id: (),
                additional_certificate_02_id: (),
                additional_certificate_03_id: (),
                additional_certificate_04_id: (),
                additional_certificate_05_id: (),
                birth_certificate_back_id: (),
                birth_certificate_front_id: (),
                document_type: (),
                nic_back_id: (),
                nic_front_id: (),
                al_certificate_id:(),
                ol_certificate_id:(),
                document: (),
                folder_id: ()
               };

    drive:FileContent|error document_file_stream = check driveClient->getFileContent(id);

    if(document_file_stream is  drive:FileContent){
        byte[] base64EncodedDocument = <byte[]>(check mime:base64Encode(document_file_stream.content));
        string base64EncodedStringDocument = check string:fromBytes(base64EncodedDocument);
        user_document.document_type = document_name;
        user_document.document = base64EncodedStringDocument;
    }else{
        user_document.document_type = ();
        user_document.document = ();
    }
    return  user_document;
}

