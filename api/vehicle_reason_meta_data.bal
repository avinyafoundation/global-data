public isolated service class VehicleReasonMetaData {

    private VehicleReasonMetadata vehicle_reason_metadata;

    isolated function init(int? id = 0, VehicleReasonMetadata? vehicleReasonMetadata = null) returns error? {

        if (vehicleReasonMetadata != null) {
            self.vehicle_reason_metadata = vehicleReasonMetadata.cloneReadOnly();
            return;
        }

        lock {

            VehicleReasonMetadata vehicle_reason_metadata_raw;

            if (id > 0) {

                vehicle_reason_metadata_raw = check db_client->queryRow(
                `SELECT *
                FROM vehicle_reason_metadata
                WHERE id = ${id};`);

            }else{
                return error("No id provided");
            }

            self.vehicle_reason_metadata = vehicle_reason_metadata_raw.cloneReadOnly();

        }

    }

    isolated resource function get id() returns int?|error {
        lock {
            return self.vehicle_reason_metadata.id;
        }
    }

    isolated resource function get reason() returns string? {
        lock {
            return self.vehicle_reason_metadata.reason;
        }
    }

    isolated resource function get created() returns string? {
        lock {
            return self.vehicle_reason_metadata.created;
        }
    }
}
