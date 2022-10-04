public distinct service class OrganizationData {
    private Organization organization;

    isolated function init(string? name = null, int? organization_id = 0, Organization? organization = null) returns error? {
        if(organization != null) { // if roganization is provided, then use that and do not load from DB
            self.organization = organization.cloneReadOnly();
            return;
        }

        string _name = "%" + (name ?: "") + "%";
        int id = organization_id ?: 0;

        Organization org_raw;
        if(id > 0) { // organization_id provided, give precedance to that
            org_raw = check db_client -> queryRow(
            `SELECT *
            FROM avinya_db.organization
            WHERE
                id = ${id};`);
        } else 
        {
            org_raw = check db_client -> queryRow(
            `SELECT *
            FROM avinya_db.organization
            WHERE
                name_en LIKE ${_name};`);
        }
        
        self.organization = org_raw.cloneReadOnly();
    }

    isolated resource function get address() returns AddressData|error? {
        int id = self.organization.address_id ?: 0;
        if( id == 0) {
            return null; // no point in querying if address id is null
        } 
        
        return new AddressData(id);
    }

    resource function get avinya_type() returns AvinyaTypeData|error? {
        int id = self.organization.avinya_type ?: 0;
        if(id == 0) {
            return null; // no point in querying if avinya type is null
        }
        return new AvinyaTypeData(id);
    }

    resource function get phone() returns int? {
        return self.organization.phone;
    }

    resource function get name() returns LocalizedName {
        return {
            "name_en": self.organization["name_en"],
            "name_si": self.organization["name_si"]?:"", // handle null cases 
            "name_ta": self.organization["name_ta"]?:""
        };
    }

    resource function get child_organizations() returns OrganizationData[]|error? {
        // Get list of child organizations
        stream<ParentChildOrganization, error?> child_org_ids = db_client->query(
            `SELECT *
            FROM avinya_db.parent_child_organization
            WHERE parent_org_id = ${self.organization.id}`
        );

        OrganizationData[] child_orgs = [];

        check from ParentChildOrganization pco in child_org_ids
            do {
                OrganizationData|error candidate_org = new OrganizationData((), pco.child_org_id);
                if !(candidate_org is error) {
                    child_orgs.push(candidate_org);
                }
            };

        return child_orgs;
    }

    resource function get parent_organizations() returns OrganizationData[]|error? {
        // Get list of child organizations
        stream<ParentChildOrganization, error?> parent_org_ids = db_client->query(
            `SELECT *
            FROM avinya_db.parent_child_organization
            WHERE child_org_id = ${self.organization.id}`
        );

        OrganizationData[] parent_orgs = [];

        check from ParentChildOrganization pco in parent_org_ids
            do {
                OrganizationData|error candidate_org = new OrganizationData((), pco.parent_org_id);
                if !(candidate_org is error) {
                    parent_orgs.push(candidate_org);
                }
            };

        return parent_orgs;
    }

    resource function get persons() returns PersonData[]|error? {
        // Get list of child organizations
        stream<Person, error?> people = db_client->query(
            `SELECT *
            FROM avinya_db.person
            WHERE organization_id = ${self.organization.id}`
        );

        PersonData[] peopleData = [];

        check from Person person in people
            do {
                PersonData|error personData = new PersonData((), 0, person);
                if !(personData is error) {
                    peopleData.push(personData);
                }
            };

        return peopleData;
    }
}
