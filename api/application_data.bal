public isolated service class ApplicationData {
    private Application application = {id:0, person_id: 0, vacancy_id: 0, application_date: ()};

    isolated function init(int? application_id = 0, int? person_id = 0, Application? application = null) returns error? {
        if(application != null) { // if application is provided, then use that and do not load from DB
            self.application = application.cloneReadOnly();
            return;
        }

        int id = application_id ?: 0;

        if(id > 0) { // application_id provided, give precedance to that
            Application application_raw = check db_client -> queryRow(
            `SELECT *
            FROM application
            WHERE
                id = ${id};`);
        
            self.application = application_raw.cloneReadOnly();
            return ;
        }

        int _person_id = person_id ?: 0;

        if(_person_id > 0) { 
            Application application_raw = check db_client -> queryRow(
            `SELECT *
            FROM application
            WHERE
                person_id = ${_person_id};`);
        
            self.application = application_raw.cloneReadOnly();
            return ;
        }

    }

    isolated resource function get id() returns int? {
        lock {
                return self.application.id;
        }
    }

    
    isolated resource function get applicant() returns PersonData|error? {
        int id = 0;
        lock {
            id = self.application.person_id ?: 0;
            if( id == 0) {
                return null; // no point in querying if person id is null
            } 
        }
        
        return new PersonData((), id);
    }

    isolated resource function get vacancy() returns VacancyData|error? {
        int id = 0;
        lock {
            id = self.application.vacancy_id ?: 0;
            if( id == 0) {
                return null; // no point in querying if person id is null
            } 
        }
        
        return new VacancyData((), id);
    }

    isolated resource function get application_date() returns string? {
        lock {
                return self.application.application_date;
        }
    }

    isolated resource function get statuses() returns ApplicationStatusData[]|error? {
        int id = 0;
        lock {
            id = self.application.id ?: 0;
            if( id == 0) {
                return null; // no point in querying if applcation id is null
            } 
        }

        stream<ApplicationStatus, error?> application_status_stream;
        lock {
            application_status_stream = db_client->query(
                `SELECT *
                FROM application_status
                WHERE application_id = ${self.application.id}`
            );
        }

        ApplicationStatusData[] applicatonStatuses = [];

        check from ApplicationStatus applicationStatus in application_status_stream
            do {
                ApplicationStatusData|error statusData = new ApplicationStatusData(0, applicationStatus);
                if !(statusData is error) {
                    applicatonStatuses.push(statusData);
                }
            };
        check application_status_stream.close();
        return applicatonStatuses;
        
    }

}

public isolated service class ApplicationStatusData {
    private ApplicationStatus application_status = {id:0, application_id: 0, status: (), is_terminal: false, updated: ()}; 

    isolated function init(int? application_id = 0, ApplicationStatus? application_status = null) returns error? {
        if(application_status != null) { // if application_status is provided, then use that and do not load from DB
            self.application_status = application_status.cloneReadOnly();
            return;
        }

        int _application_id = application_id ?: 0;

        if(_application_id > 0) { // application_status_id provided, give precedance to that
            ApplicationStatus application_raw = check db_client -> queryRow(
            `SELECT *
            FROM application_status
            WHERE
                application_id = ${_application_id};`);
            
            self.application_status = application_raw.cloneReadOnly();
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
