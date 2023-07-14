public isolated service class InventoryData{
    private Inventory inventory;

    isolated function init(int id,Inventory? inventory=null) returns error?{
        if(inventory != null){
            self.inventory = inventory.cloneReadOnly();
            return;
        }
        lock{
            Inventory inventory_raw = check db_client->queryRow(
                `SELECT *
                FROM inventory
                WHERE id = ${id};`
            );
            self.inventory = inventory_raw.cloneReadOnly();
        }
    }

    isolated resource function get id() returns int?|error {
        lock {
            return self.inventory.id;
        }
    }

    //2023-06-23 fixed the issue from lahiru
    isolated resource function get avinya_type() returns AvinyaTypeData|error? {
        int id = 0;
        lock {
            id = self.inventory.avinya_type_id ?: 0;
            if( id == 0) {
                return null; // no point in querying if address id is null
            } 
        }
        return new AvinyaTypeData(id);
    }


     //2023-06-23 fixed the issue from lahiru
    isolated resource function get avinya_type_id() returns int?|error? {
       
        lock {
           return self.inventory.avinya_type_id;
        }
       
    }


    isolated resource function get asset() returns AssetData|error? {
        int id = 0;
        lock {
            id = self.inventory.asset_id ?: 0;
            if( id == 0) {
                return null; // no point in querying if address id is null
            } 
        }
        return new AssetData(id);
    }

    isolated resource function get consumable() returns ConsumableData|error? {
        int id = 0;
        lock {
            id = self.inventory.consumable_id ?: 0;
            if( id == 0) {
                return null; // no point in querying if address id is null
            } 
        }
        return new ConsumableData(id);
    }

    isolated resource function get organization() returns OrganizationData|error? {
        int id = 0;
        lock {
            id = self.inventory.organization_id ?: 0;
            if( id == 0) {
                return null; // no point in querying if address id is null
            } 
        }
        return new OrganizationData((),id);
    }

    isolated resource function get person() returns PersonData|error? {
        int id = 0;
        lock {
            id = self.inventory.person_id ?: 0;
            if( id == 0) {
                return null; // no point in querying if address id is null
            } 
        }
        return new PersonData((),id);
    }

    isolated resource function get quantity() returns int?|error {
        lock {
            return self.inventory.quantity;
        }
    }

    isolated resource function get quantity_in() returns int?|error {
        lock {
            return self.inventory.quantity_in;
        }
    }

    isolated resource function get quantity_out() returns int?|error {
        lock {
            return self.inventory.quantity_out;
        }
    }

    isolated resource function get created() returns string?|error {
        lock {
            return self.inventory.created;
        }
    }

    isolated resource function get updated() returns string?|error {
        lock {
            return self.inventory.updated;
        }
    }
    
}

