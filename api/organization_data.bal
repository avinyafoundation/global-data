public isolated service class OrganizationData {
    private Organization organization;

    isolated function init(string? name = null, int? organization_id = 0, Organization? organization = null) returns error? {
        if(organization != null) { // if organization is provided, then use that and do not load from DB
            self.organization = organization.cloneReadOnly();
            return;
        }

        string _name = "%" + (name ?: "") + "%";
        int id = organization_id ?: 0;

        Organization org_raw;
        if(id > 0) { // organization_id provided, give precedance to that
            org_raw = check db_client -> queryRow(
            `SELECT *
            FROM organization
            WHERE
                id = ${id};`);
        } else 
        {
            org_raw = check db_client -> queryRow(
            `SELECT *
            FROM organization
            WHERE
                name_en LIKE ${_name};`);
        }
        
        self.organization = org_raw.cloneReadOnly();
    }

    isolated resource function get id() returns int? {
        lock {
                return self.organization.id;
        }
    }

    isolated resource function get description() returns string?{
        lock {
            return self.organization.description;
        }
    }

    isolated resource function get notes() returns string?{
        lock {
            return self.organization.notes;
        }
    }

    isolated resource function get address() returns AddressData|error? {
        int id = 0;
        lock {
            id = self.organization.address_id ?: 0;
            if( id == 0) {
                return null; // no point in querying if address id is null
            } 
            
        }
        
        return new AddressData(id);
    }

    isolated resource function get avinya_type() returns AvinyaTypeData|error? {
        int id = 0;
        lock {
            id = self.organization.avinya_type ?: 0;
            if( id == 0) {
                return null; // no point in querying if address id is null
            } 
        }
        
        return new AvinyaTypeData(id);
    }

    isolated resource function get phone() returns int? {
        lock {
            return self.organization.phone;
        }
    }

    isolated resource function get name() returns LocalizedName {
        lock {
            return {
                "name_en": self.organization["name_en"],
                "name_si": self.organization["name_si"]?:"", // handle null cases 
                "name_ta": self.organization["name_ta"]?:""
            };
        }
    }

    isolated resource function get child_organizations() returns OrganizationData[]|error? {
        // Get list of child organizations
        stream<ParentChildOrganization, error?> child_org_ids;
        lock {
            child_org_ids = db_client->query(
                `SELECT *
                FROM parent_child_organization
                WHERE parent_org_id = ${self.organization.id} AND parent_org_id != 17`
            );
        }

        OrganizationData[] child_orgs = [];

        check from ParentChildOrganization pco in child_org_ids
            do {
                OrganizationData|error candidate_org = new OrganizationData((), pco.child_org_id);
                if !(candidate_org is error) {
                    child_orgs.push(candidate_org);
                }
            };
        check child_org_ids.close();
        return child_orgs;
    }

    isolated resource function get parent_organizations() returns OrganizationData[]|error? {
        // Get list of child organizations
        stream<ParentChildOrganization, error?> parent_org_ids;
        lock {
            parent_org_ids = db_client->query(
                `SELECT *
                FROM parent_child_organization
                WHERE child_org_id = ${self.organization.id}`
            );
        }

        OrganizationData[] parent_orgs = [];

        check from ParentChildOrganization pco in parent_org_ids
            do {
                OrganizationData|error candidate_org = new OrganizationData((), pco.parent_org_id);
                if !(candidate_org is error) {
                    parent_orgs.push(candidate_org);
                }
            };
        check parent_org_ids.close();
        return parent_orgs;
    }

    isolated resource function get people() returns PersonData[]|error? {
        // Get list of people in the organization
        stream<Person, error?> people;
        lock {
            people = db_client->query(
                `SELECT *
                FROM person
                WHERE organization_id = ${self.organization.id} AND avinya_type_id=37`
            );
        }

        PersonData[] peopleData = [];

        check from Person person in people
            do {
                PersonData|error personData = new PersonData((), 0, person);
                if !(personData is error) {
                    peopleData.push(personData);
                }
            };

        check people.close();
        return peopleData;
    }

    isolated resource function get vacancies() returns VacancyData[]|error? {
        // Get list of people in the organization
        stream<Vacancy, error?> vacancies;
        lock {
            vacancies = db_client->query(
                `SELECT *
                FROM vacancy
                WHERE organization_id = ${self.organization.id} AND
                    evaluation_cycle_id IN (
                        SELECT id 
                        FROM evaluation_cycle 
                        WHERE (CURRENT_DATE) BETWEEN start_date AND end_date)`
            );
        }

        VacancyData[] vacanciesData = [];

        check from Vacancy vacancy in vacancies
            do {
                VacancyData|error vacancyData = new VacancyData((), 0, vacancy);
                if !(vacancyData is error) {
                    vacanciesData.push(vacancyData);
                }
            };

        check vacancies.close();

        return vacanciesData;
    }

    isolated resource function get organization_metadata() returns OrganizationMetaData[]|error? {
       
        stream<OrganizationMetaDataDetails, error?> org_meta_data;
        lock {
            org_meta_data = db_client->query(
                `SELECT *
                FROM organization_metadata
                WHERE organization_id = ${self.organization.id}`
            );
        }

        OrganizationMetaData[] org_meta_data_details = [];

        check from OrganizationMetaDataDetails orgmetdatadetails in org_meta_data
            do {
                OrganizationMetaData|error org_meta_data_det = new OrganizationMetaData((),(),orgmetdatadetails);
                if !(org_meta_data_det is error) {
                    org_meta_data_details.push(org_meta_data_det);
                }
            };
        check org_meta_data.close();
        return org_meta_data_details;
    }

}
