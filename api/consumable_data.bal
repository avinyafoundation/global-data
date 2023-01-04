public isolated service class ConsumableData{
    private Consumable consumable;

    isolated function init(int id,Consumable? consumable=null) returns error?{
        if(consumable != null){
            self.consumable = consumable.cloneReadOnly();
            return;
        }
        lock{
            Consumable consumable_raw = check db_client->queryRow(
                `SELECT *
                FROM avinya_db.consumable
                WHERE id = ${id};`
            );
            self.consumable = consumable_raw.cloneReadOnly();
        }
    }

    isolated resource function get id() returns int?|error {
        lock {
            return self.consumable.id;
        }
    }

    isolated resource function get avinya_type() returns AvinyaTypeData|error? {
        int id = 0;
        lock {
            id = self.consumable.avinya_type_id ?: 0;
            if( id == 0) {
                return null; // no point in querying if address id is null
            } 
        }
        return new AvinyaTypeData(id);
    }

    isolated resource function get name() returns string?|error {
        lock {
            return self.consumable.name;
        }
    }

    isolated resource function get description() returns string?|error {
        lock {
            return self.consumable.description;
        }
    }

    isolated resource function get manufacturer() returns string?|error {
        lock {
            return self.consumable.manufacturer;
        }
    }

    isolated resource function get model() returns string?|error {
        lock {
            return self.consumable.model;
        }
    }

    isolated resource function get serial_number() returns string?|error {
        lock {
            return self.consumable.serial_number;
        }
    }

    isolated resource function get created() returns string?|error {
        lock {
            return self.consumable.created;
        }
    }

    isolated resource function get updated() returns string?|error {
        lock {
            return self.consumable.updated;
        }
    }
    
}

