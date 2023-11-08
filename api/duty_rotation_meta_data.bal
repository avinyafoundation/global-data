public isolated service class DutyRotationMetaData{

  private  DutyRotationMetaDetails duty_rotation_metadata;

   isolated function init(int? id=0,int? organization_id=0,DutyRotationMetaDetails? dutyRotationMetadata = null) returns error? {
        
        if(dutyRotationMetadata != null) { 
            self.duty_rotation_metadata = dutyRotationMetadata.cloneReadOnly();
            return;
        }

        DutyRotationMetaDetails duty_rotation_metadata_raw;
        
        if(id>0){

        duty_rotation_metadata_raw = check db_client -> queryRow(
            `SELECT *
            FROM duty_rotation_metadata
            WHERE id = ${id};`
        );

        }else{

        duty_rotation_metadata_raw = check db_client -> queryRow(
            `SELECT *
            FROM duty_rotation_metadata
            WHERE organization_id = ${organization_id};`
        );
        
        }

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

    isolated resource function get organization_id() returns int?{
        lock {
            return self.duty_rotation_metadata.organization_id;
        }
    }






}