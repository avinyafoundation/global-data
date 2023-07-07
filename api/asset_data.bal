public isolated service class AssetData{
    private Asset asset;

    isolated function init(int? id = 0, int? avinya_type_id = 0, Asset? asset=null) returns error?{
        if(asset != null){
            self.asset = asset.cloneReadOnly();
            return;
        }
        
        lock{
            Asset asset_raw;
            if(id > 0 && avinya_type_id == 0) {
                asset_raw = check db_client->queryRow(
                `SELECT *
                FROM asset
                WHERE id = ${id};`);
            }else{
                asset_raw = check db_client->queryRow(
                `SELECT *
                FROM asset
                WHERE avinya_type_id = ${avinya_type_id};`);
            }
            self.asset = asset_raw.cloneReadOnly();
        }
        
    }

    isolated resource function get id() returns int?|error {
        lock {
            return self.asset.id;
        }
    }

    isolated resource function get name() returns string?|error {
        lock {
            return self.asset.name;
        }
    }

    isolated resource function get manufacturer() returns string?|error {
        lock {
            return self.asset.manufacturer;
        }
    }

    isolated resource function get model() returns string?|error {
        lock {
            return self.asset.model;
        }
    }

    isolated resource function get serial_number() returns string?|error {
        lock {
            return self.asset.serial_number;
        }
    }

    isolated resource function get registration_number() returns string?|error {
        lock {
            return self.asset.registration_number;
        }
    }

    isolated resource function get description() returns string?|error {
        lock {
            return self.asset.description;
        }
    }

    isolated resource function get avinya_type() returns AvinyaTypeData|error? {
        int id = 0;
        lock {
            id = self.asset.avinya_type_id ?: 0;
            if( id == 0) {
                return null; // no point in querying if address id is null
            } 
        }
        return new AvinyaTypeData(id);
    }


     //2023-06-23 fixed the issue from lahiru
    isolated resource function get avinya_type_id() returns int?|error? {
       
        lock {
           return self.asset.avinya_type_id;
        }
       
    }

    isolated resource function get created() returns string?|error {
        lock {
            return self.asset.created;
        }
    }

    isolated resource function get updated() returns string?|error {
        lock {
            return self.asset.updated;
        }
    }
    
}

