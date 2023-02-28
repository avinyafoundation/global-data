public isolated service class ResourceAllocationData{
    private ResourceAllocation resource_allocation;

    isolated function init(int? id = 0, int? person_id = 0, ResourceAllocation? resource_allocation=null) returns error?{
        if(resource_allocation != null){
            self.resource_allocation = resource_allocation.cloneReadOnly();
            return;
        }
     
        lock{
            ResourceAllocation resource_allocation_raw;
            if(id > 0 && person_id == 0) {
                resource_allocation_raw = check db_client->queryRow(
                `SELECT *
                FROM resource_allocation
                WHERE id = ${id};`);
            }else{
                 resource_allocation_raw = check db_client->queryRow(
                `SELECT *
                FROM resource_allocation
                WHERE person_id = ${person_id};`);
            }
            self.resource_allocation = resource_allocation_raw.cloneReadOnly();
        }
    }

    isolated resource function get id() returns int?|error {
        lock {
            return self.resource_allocation.id;
        }
    }

    isolated resource function get requested() returns boolean?|error {
        lock {
            return self.resource_allocation.requested;
        }
    }

    isolated resource function get approved() returns boolean?|error {
        lock {
            return self.resource_allocation.approved;
        }
    }

    isolated resource function get allocated() returns boolean?|error {
        lock {
            return self.resource_allocation.allocated;
        }
    }

    isolated resource function get asset() returns AssetData|error? {
        int id = 0;
        lock {
            id = self.resource_allocation.asset_id ?: 0;
            if( id == 0) {
                return null; // no point in querying if address id is null
            } 
        }
        return new AssetData(id);
    }

    isolated resource function get consumable() returns ConsumableData|error? {
        int id = 0;
        lock {
            id = self.resource_allocation.consumable_id ?: 0;
            if( id == 0) {
                return null; // no point in querying if address id is null
            } 
        }
        return new ConsumableData(id);
    }

    isolated resource function get organization() returns OrganizationData|error? {
        int id = 0;
        lock {
            id = self.resource_allocation.organization_id ?: 0;
            if( id == 0) {
                return null; // no point in querying if address id is null
            } 
        }
        return new OrganizationData((),id);
    }
    
    isolated resource function get person() returns PersonData|error? {
        int id = 0;
        lock {
            id = self.resource_allocation.person_id ?: 0;
            if( id == 0) {
                return null; // no point in querying if address id is null
            } 
        }
        return new PersonData((),id);
    }

    isolated resource function get quantity() returns int?|error {
        lock {
            return self.resource_allocation.quantity;
        }
    }

    isolated resource function get start_date() returns string?|error {
        lock {
            return self.resource_allocation.start_date;
        }
    }

    isolated resource function get end_date() returns string?|error {
        lock {
            return self.resource_allocation.end_date;
        }
    }

    isolated resource function get created() returns string?|error {
        lock {
            return self.resource_allocation.created;
        }
    }

    isolated resource function get updated() returns string?|error {
        lock {
            return self.resource_allocation.updated;
        }
    }
}

