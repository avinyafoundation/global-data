public isolated service class ResourcePropertyData{
    private ResourceProperty resource_property;

    isolated function init(int id,ResourceProperty? resource_property=null) returns error?{
        if(resource_property != null){
            self.resource_property = resource_property.cloneReadOnly();
            return;
        }
        lock{
            ResourceProperty resource_property_raw = check db_client->queryRow(
                `SELECT *
                FROM avinya_db.resource_property
                WHERE id = ${id};`
            );
            self.resource_property = resource_property_raw.cloneReadOnly();
        }
    }

    isolated resource function get id() returns int?|error {
        lock {
            return self.resource_property.id;
        }
    }

    isolated resource function get asset() returns AssetData|error? {
        int id = 0;
        lock {
            id = self.resource_property.asset_id ?: 0;
            if( id == 0) {
                return null; // no point in querying if address id is null
            } 
        }
        return new AssetData(id);
    }
    
    isolated resource function get consumable() returns ConsumableData|error? {
        int id = 0;
        lock {
            id = self.resource_property.consumable_id ?: 0;
            if( id == 0) {
                return null; // no point in querying if address id is null
            } 
        }
        return new ConsumableData(id);
    }

    isolated resource function get property() returns string?|error {
        lock {
            return self.resource_property.property;
        }
    }

    isolated resource function get value() returns string?|error {
        lock {
            return self.resource_property.value;
        }
    }

}

