public isolated service class VehicleFuelConsumptionData {

    private VehicleFuelConsumption vehicle_fuel_consumption;

    isolated function init(int? id = 0, VehicleFuelConsumption? vehicleFuelConsumption = null) returns error? {

        if (vehicleFuelConsumption != null) {
            self.vehicle_fuel_consumption = vehicleFuelConsumption.cloneReadOnly();
            return;
        }

        lock {

            VehicleFuelConsumption vehicle_fuel_consumption_raw;

            if (id > 0) {

                vehicle_fuel_consumption_raw = check db_client->queryRow(
                `SELECT *
                FROM vehicle_fuel_consumption
                WHERE id = ${id};`);

            } else {
                return error("No id provided");
            }

            self.vehicle_fuel_consumption = vehicle_fuel_consumption_raw.cloneReadOnly();

        }

    }

    isolated resource function get id() returns int?|error {
        lock {
            return self.vehicle_fuel_consumption.id;
        }
    }

    isolated resource function get vehicle_id() returns int?|error {
        lock {
            return self.vehicle_fuel_consumption.vehicle_id;
        }
    }

    isolated resource function get vehicle() returns VehicleData|error? {
        int id = 0;
        lock {
            id = self.vehicle_fuel_consumption.vehicle_id ?: 0;
            if (id == 0) {
                return null; // no point in querying if address id is null
            }
        }

        return new VehicleData(id);
    }

    isolated resource function get date_time() returns string? {
        lock {
            return self.vehicle_fuel_consumption.date_time;
        }
    }

    isolated resource function get reason_id() returns int?|error {
        lock {
            return self.vehicle_fuel_consumption.reason_id;
        }
    }

    isolated resource function get reason() returns VehicleReasonMetaData|error? {
        int id = 0;
        lock {
            id = self.vehicle_fuel_consumption.reason_id ?: 0;
            if (id == 0) {
                return null; // no point in querying if address id is null
            }
        }

        return new VehicleReasonMetaData(id);
    }

    isolated resource function get starting_meter() returns string? {
        lock {
            return self.vehicle_fuel_consumption.starting_meter;
        }
    }

    isolated resource function get ending_meter() returns string? {
        lock {
            return self.vehicle_fuel_consumption.ending_meter;
        }
    }

    isolated resource function get distance() returns string? {
        lock {
            return self.vehicle_fuel_consumption.distance;
        }
    }

    isolated resource function get comment() returns string? {
        lock {
            return self.vehicle_fuel_consumption.comment;
        }
    }

    isolated resource function get created() returns string? {
        lock {
            return self.vehicle_fuel_consumption.created;
        }
    }

    isolated resource function get updated() returns string? {
        lock {
            return self.vehicle_fuel_consumption.updated;
        }
    }
}
