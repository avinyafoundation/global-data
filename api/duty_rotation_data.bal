public isolated service class DutyRotationData{

  private  DutyRotationMetadata duty_rotation_metadata;

   isolated function init(int? id=0, DutyRotationMetadata? dutyRotationMetadata = null) returns error? {
        
        if(dutyRotationMetadata != null) { 
            self.duty_rotation_metadata = dutyRotationMetadata.cloneReadOnly();
            return;
        }

        DutyRotationMetadata duty_rotation_metadata_raw = check db_client -> queryRow(
            `SELECT *
            FROM duty_rotation_metadata
            WHERE id = ${id};`
        );

        self.duty_rotation_metadata = duty_rotation_metadata_raw.cloneReadOnly();
    }
   
    isolated resource function get id() returns int?|error {
        lock {
            return self.duty_rotation_metadata.id;
        }
    }

    isolated resource function get start_date() returns string?|error {
        lock {
            return self.duty_rotation_metadata.start_date;
        }
    }

    isolated resource function get end_date() returns string?|error {
        lock {
            return self.duty_rotation_metadata.end_date;
        }
    }








}