public isolated service class ApplicationData {
    private Application application = {id:0, person_id: 0, vacancy_id: 0, application_date: ()};

    isolated function init(int? application_id = 0, Application? application = null) returns error? {
        if(application != null) { // if application is provided, then use that and do not load from DB
            self.application = application.cloneReadOnly();
            return;
        }

        int id = application_id ?: 0;

        if(id > 0) { // application_id provided, give precedance to that
            Application org_raw = check db_client -> queryRow(
            `SELECT *
            FROM avinya_db.application
            WHERE
                id = ${id};`);
        
            self.application = org_raw.cloneReadOnly();
            return ;
        }
    }

    isolated resource function get person_id() returns int? {
        lock {
            return self.application.person_id;
        }
    }

    isolated resource function get vacancy_id() returns int? {
        lock {
            return self.application.vacancy_id;
        }
    }

    isolated resource function get application_date() returns string? {
        lock {
                return self.application.application_date;
        }
    }

}

public isolated service class ApplicationStatusData {
    private ApplicationStatus application_status = {id:0, application_id: 0, status: (), is_terminal: false, updated: ()}; 

    isolated function init(int? application_status_id = 0, ApplicationStatus? application_status = null) returns error? {
        if(application_status != null) { // if application_status is provided, then use that and do not load from DB
            self.application_status = application_status.cloneReadOnly();
            return;
        }

        int id = application_status_id ?: 0;

        if(id > 0) { // application_status_id provided, give precedance to that
            ApplicationStatus org_raw = check db_client -> queryRow(
            `SELECT *
            FROM avinya_db.application_status
            WHERE
                id = ${id};`);
            
            self.application_status = org_raw.cloneReadOnly();
        } 
        
        
    }

    isolated resource function get application_id() returns int? {
        lock {
            return self.application_status.application_id;
        }
    }

    isolated resource function get status() returns string? {
        lock {
            return self.application_status.status;
        }
    }

    isolated resource function get updated() returns string? {
        lock {
                return self.application_status.updated;
        }
    }
    isolated resource function get is_terminal() returns boolean? {
        lock {
                return self.application_status.is_terminal;
        }
    }

}
