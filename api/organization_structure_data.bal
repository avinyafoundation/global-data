import ballerina/time;
import ballerina/log;
public isolated service class OrganizationStructureData {
    private Organization[] organizations;

    isolated function init(string? name = null, int? organization_id = 0, int? level = 0) returns error? {
        int _id = organization_id ?: 0;
        string _name = "%" + (name ?: "") + "%";
        Organization[] org_raws = [];

        time:Utc utcTimeBefore = time:utcNow();

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

        time:Utc utcTimeAfter = time:utcNow();
        time:Seconds seconds = time:utcDiffSeconds(utcTimeAfter, utcTimeBefore);

        log:printInfo("Time taken to query execution in OrganizationStructureData in seconds = " + seconds.toString()); 
        
        self.organizations = org_raws.cloneReadOnly();
    }

    isolated resource function get organizations() returns OrganizationData[]|error? {
        OrganizationData[] organizationDataArray = [];
        Organization[] organizations = [];

        lock {
            organizations = self.organizations.cloneReadOnly();
        }

        foreach var organization in organizations {
            organizationDataArray.push(check new OrganizationData(organization = organization));
        }
        
        return organizationDataArray;
    }
}
