public isolated service class OrganizationLocationData {

    private OrganizationLocation organization_location;

    isolated function init(int? id = 0, OrganizationLocation? organizationLocation = null) returns error? {

        if (organizationLocation != null) {
            self.organization_location = organizationLocation.cloneReadOnly();
            return;
        }

        lock {
            OrganizationLocation organization_location_raw;

            if (id > 0) {

                organization_location_raw = check db_client->queryRow(
                `SELECT *
                FROM organization_location
                WHERE id = ${id};`);

            } else {
                return error("Invalid request : id must be greater than 0");
            }

            self.organization_location = organization_location_raw.cloneReadOnly();

        }
    }

    isolated resource function get id() returns int?|error {
        lock {
            return self.organization_location.id;
        }
    }

    isolated resource function get organization_id() returns int?|error {
        lock {
            return self.organization_location.organization_id;
        }
    }

    isolated resource function get location_name() returns string?|error {
        lock {
            return self.organization_location.location_name;
        }
    }

    isolated resource function get description() returns string?|error {
        lock {
            return self.organization_location.description;
        }
    }
}
