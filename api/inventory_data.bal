public isolated service class InventoryData{
    private Inventory inventory;

    isolated function init(int? id = 0, Inventory? inventory = null) returns error? {
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

     isolated resource function get consumable_id() returns int|error? {
        lock {
            return self.inventory.consumable_id ?: 0;
        }
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

    isolated resource function get quantity() returns decimal?|error {
        lock {
            return self.inventory.quantity;
        }
    }

    isolated resource function get quantity_in() returns decimal?|error {
        lock {
            return self.inventory.quantity_in;
        }
    }

    isolated resource function get quantity_out() returns decimal?|error {
        lock {
            return self.inventory.quantity_out;
        }
    }


    isolated resource function get prev_quantity() returns decimal?|error {
        lock {
            return self.inventory.prev_quantity;
        }
    }

    isolated resource function get resource_property() returns ResourcePropertyData|error? {
        int id = 0;
        lock {
            id = self.inventory.resource_property_id ?: 0;
            if( id == 0) {
                return null; // no point in querying if address id is null
            } 
        }
        return new ResourcePropertyData(id);
    }

    
    isolated resource function get name() returns string?|error {
        lock {
            return self.inventory.name;
        }
    }


    isolated resource function get description() returns string?|error {
        lock {
            return self.inventory.description;
        }
    }


    isolated resource function get manufacturer() returns string?|error {
        lock {
            return self.inventory.manufacturer;
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

