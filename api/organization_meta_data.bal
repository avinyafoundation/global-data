public isolated service class OrganizationMetaData{

  private  OrganizationMetaDataDetails organization_metadata;

   isolated function init(int? id=0,int? organization_id=0,OrganizationMetaDataDetails? organizationMetadata = null) returns error? {
        
        if(organizationMetadata != null) { 
            self.organization_metadata = organizationMetadata.cloneReadOnly();
            return;
        }

        OrganizationMetaDataDetails organization_metadata_raw;
        
        if(id>0){

        organization_metadata_raw = check db_client -> queryRow(
            `SELECT *
            FROM organization_metadata
            WHERE id = ${id};`
        );

        }else{

        organization_metadata_raw = check db_client -> queryRow(
            `SELECT *
            FROM organization_metadata
            WHERE organization_id = ${organization_id};`
        );
        
        }

        self.organization_metadata = organization_metadata_raw.cloneReadOnly();
    }
   
    isolated resource function get id() returns int?|error {
        lock {
            return self.organization_metadata.id;
        }
    }

    isolated resource function get organization_id() returns int?{
        lock {
            return self.organization_metadata.organization_id;
        }
    }

    isolated resource function get key_name() returns string?|error{
        lock {
            return self.organization_metadata.key_name;
        }
    }

    isolated resource function get value() returns string?|error{
        lock {
            return self.organization_metadata.value;
        }
    }


}