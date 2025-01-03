public isolated service class DocumentsData {
    private UserDocument document_list;

    isolated function init(int? id = 0, UserDocument? documentList = null) returns error? {

        if (documentList != null) {
            self.document_list = documentList.cloneReadOnly();
            return;
        }
        lock {

            UserDocument documents_raw;

            if (id > 0) {

             documents_raw = check db_client->queryRow(
                `SELECT *
                FROM user_documents
                WHERE id = ${id};`);

            }else{
              return error("No id provided");
            }
            self.document_list = documents_raw.cloneReadOnly();
        }
    }

    isolated resource function get id() returns int?|error {
        lock {
            return self.document_list.id;
        }
    }

    isolated resource function get folder_id() returns string?|error {
       lock{
         return self.document_list.folder_id;
       }
    }

    isolated resource function get nic_front_id() returns string?|error {
        lock {
            return self.document_list.nic_front_id;
        }
    }

    isolated resource function get nic_back_id() returns string?|error {
        lock {
            return self.document_list.nic_back_id;
        }
    }

    isolated resource function get birth_certificate_front_id() returns string?|error {
        lock {
            return self.document_list.birth_certificate_front_id;
        }
    }

    isolated resource function get birth_certificate_back_id() returns string?|error {
        lock {
            return self.document_list.birth_certificate_back_id;
        }
    }

    isolated resource function get ol_certificate_id() returns string?|error {
        lock {
            return self.document_list.ol_certificate_id;
        }
    }

    isolated resource function get al_certificate_id() returns string?|error {
        lock {
            return self.document_list.al_certificate_id;
        }
    }

    isolated resource function get additional_certificate_01_id() returns string?|error {
        lock {
            return self.document_list.additional_certificate_01_id;
        }
    }

    isolated resource function get additional_certificate_02_id() returns string?|error {
        lock {
            return self.document_list.additional_certificate_02_id;
        }
    }

    isolated resource function get additional_certificate_03_id() returns string?|error {
        lock {
            return self.document_list.additional_certificate_03_id;
        }
    }

    isolated resource function get additional_certificate_04_id() returns string?|error {
        lock {
            return self.document_list.additional_certificate_04_id;
        }
    }

    isolated resource function get additional_certificate_05_id() returns string?|error {
        lock {
            return self.document_list.additional_certificate_05_id;
        }
    }

    isolated resource function get document_type() returns string?|error {
        lock {
            return self.document_list.document_type;
        }
    }

    isolated resource function get document() returns string?|error {
        lock {
            return self.document_list.document;
        }
    }
}

