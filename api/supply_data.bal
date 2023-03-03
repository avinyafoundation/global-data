public isolated service class SupplyData{
    private Supply supply;

    isolated function init(int id,Supply? supply=null) returns error?{
        if(supply != null){
            self.supply = supply.cloneReadOnly();
            return;
        }
        lock{
            Supply supply_raw = check db_client->queryRow(
                `SELECT *
                FROM supply
                WHERE id = ${id};`
            );
            self.supply = supply_raw.cloneReadOnly();
        }
    }

    isolated resource function get id() returns int?|error {
        lock {
            return self.supply.id;
        }
    }

    isolated resource function get asset() returns AssetData|error? {
        int id = 0;
        lock {
            id = self.supply.asset_id ?: 0;
            if( id == 0) {
                return null; // no point in querying if address id is null
            } 
        }
        return new AssetData(id);
    }

    isolated resource function get consumable() returns ConsumableData|error? {
        int id = 0;
        lock {
            id = self.supply.consumable_id ?: 0;
            if( id == 0) {
                return null; // no point in querying if address id is null
            } 
        }
        return new ConsumableData(id);
    }

    isolated resource function get supplier() returns SupplierData|error? {
        int id = 0;
        lock {
            id = self.supply.supplier_id ?: 0;
            if( id == 0) {
                return null; // no point in querying if address id is null
            } 
        }
        return new SupplierData(id);
    }

    isolated resource function get person() returns PersonData|error? {
        int id = 0;
        lock {
            id = self.supply.person_id ?: 0;
            if( id == 0) {
                return null; // no point in querying if address id is null
            } 
        }
        return new PersonData((),id);
    }

    isolated resource function get order_date() returns string?|error {
        lock {
            return self.supply.order_date;
        }
    }

    isolated resource function get delivery_date() returns string?|error {
        lock {
            return self.supply.delivery_date;
        }
    }

    isolated resource function get order_id() returns string?|error {
        lock {
            return self.supply.order_id;
        }
    }

    isolated resource function get order_amount() returns int?|error {
        lock {
            return self.supply.order_amount;
        }
    }

    isolated resource function get created() returns string?|error {
        lock {
            return self.supply.created;
        }
    }

    isolated resource function get updated() returns string?|error {
        lock {
            return self.supply.updated;
        }
    }

    
}

