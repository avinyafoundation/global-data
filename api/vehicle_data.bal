public isolated service class VehicleData {

    private Vehicle vehicle;

    isolated function init(int? id = 0, int? person_id = 0, Vehicle? vehicle = null) returns error? {

        if (vehicle != null) {
            self.vehicle = vehicle.cloneReadOnly();
            return;
        }

        lock {

            Vehicle vehicle_raw;

            if (id > 0) {

                vehicle_raw = check db_client->queryRow(
                `SELECT *
                FROM vehicle
                WHERE id = ${id};`);

            } else {
                vehicle_raw = check db_client->queryRow(
            `SELECT *
            FROM vehicle
            WHERE
                person_id = ${person_id};`);
            }

            self.vehicle = vehicle_raw.cloneReadOnly();

        }

    }

    isolated resource function get id() returns int?|error {
        lock {
            return self.vehicle.id;
        }
    }

    isolated resource function get vehicle_number() returns string? {
        lock {
            return self.vehicle.vehicle_number;
        }
    }

    isolated resource function get organization() returns OrganizationData|error? {
        int id = 0;
        lock {
            id = self.vehicle.organization_id ?: 0;
            if (id == 0) {
                return null; // no point in querying if address id is null
            }
        }

        return new OrganizationData((), id);
    }

    isolated resource function get person_id() returns int? {
        lock {
            return self.vehicle.person_id;
        }
    }

    isolated resource function get person() returns PersonData|error? {
        int id = 0;
        lock {
            id = self.vehicle.person_id ?: 0;
            if (id == 0) {
                return null;
            }

        }

        return new PersonData((), id);
    }


    isolated resource function get created() returns string? {
        lock {
            return self.vehicle.created;
        }
    }

    isolated resource function get updated() returns string? {
        lock {
            return self.vehicle.updated;
        }
    }

}
