public distinct service class OrganizationStructureData {
    private Organization[] organizations;

    isolated function init(string? name = null, int? organization_id = 0, int? level = 0) returns error? {
        int _id = organization_id ?: 0;
        string _name = "%" + (name ?: "") + "%";
        Organization[] org_raws = [];
        stream<Organization, error?> resultStream =  db_client -> query(
            `SELECT *
            FROM avinya_db.organization AS org
            WHERE
                (org.id = ${_id}
                OR org.name_en LIKE ${_name}) 
                AND 
                org.avinya_type IN 
                (SELECT atype.id FROM avinya_db.avinya_type AS atype WHERE atype.level >= ${level});`
        );

        check from Organization organization in resultStream
        do {
            org_raws.push(organization);
        };
        check resultStream.close();

        self.organizations = org_raws.cloneReadOnly();
    }

    isolated resource function get organizations() returns OrganizationData[]|error? {
        OrganizationData[] organizationDataArray = [];
        foreach var organization in self.organizations {
            organizationDataArray.push(check new OrganizationData(organization = organization));
        }
        return organizationDataArray;
    }

    // resource function get address() returns AddressData|error? {
    //     int id = self.organization.address_id ?: 0;
    //     return new AddressData(id);
    // }

    // resource function get avinya_type() returns AvinyaTypeData|error? {
    //     int id = self.organization.avinya_type ?: 0;
    //     return new AvinyaTypeData(id);
    // }

    // resource function get phone() returns int? {
    //     return self.organization.phone;
    // }

    // resource function get name() returns LocalizedName {
    //     return {
    //         "name_en": self.organization["name_en"],
    //         "name_si": <string>self.organization["name_si"],
    //         "name_ta": <string>self.organization["name_ta"]
    //     };
    // }

    // resource function get child_organizations() returns OrganizationStructureData[]|error? {
    //     // Get list of child organizations
    //     stream<ParentChildOrganization, error?> child_org_ids = db_client->query(
    //         `SELECT *
    //         FROM avinya_db.parent_child_organization
    //         WHERE parent_org_id = ${self.organization.id}`
    //     );

    //     OrganizationStructureData[] child_orgs = [];

    //     check from ParentChildOrganization pco in child_org_ids
    //         do {
    //             OrganizationStructureData|error candidate_org = new OrganizationStructureData((), pco.child_org_id);
    //             if !(candidate_org is error) {
    //                 child_orgs.push(candidate_org);
    //             }
    //         };

    //     return child_orgs;
    // }

    // resource function get parent_organizations() returns OrganizationStructureData[]|error? {
    //     // Get list of child organizations
    //     stream<ParentChildOrganization, error?> parent_org_ids = db_client->query(
    //         `SELECT *
    //         FROM avinya_db.parent_child_organization
    //         WHERE parent_org_id = ${self.organization.id}`
    //     );

    //     OrganizationStructureData[] parent_orgs = [];

    //     check from ParentChildOrganization pco in parent_org_ids
    //         do {
    //             OrganizationStructureData|error candidate_org = new OrganizationStructureData((), pco.parent_org_id);
    //             if !(candidate_org is error) {
    //                 parent_orgs.push(candidate_org);
    //             }
    //         };

    //     return parent_orgs;
    // 

}
