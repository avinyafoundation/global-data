public isolated service class SupplierData{
    private Supplier supplier;

    isolated function init(int id,Supplier? supplier=null) returns error?{
        if(supplier != null){
            self.supplier = supplier.cloneReadOnly();
            return;
        }
        lock{
            Supplier supplier_raw = check db_client->queryRow(
                `SELECT *
                FROM supplier
                WHERE id = ${id};`
            );
            self.supplier = supplier_raw.cloneReadOnly();
        }
    }

    isolated resource function get id() returns int?|error {
        lock {
            return self.supplier.id;
        }
    }

    isolated resource function get name() returns string?|error {
        lock {
            return self.supplier.name;
        }
    }

    isolated resource function get description() returns string?|error {
        lock {
            return self.supplier.description;
        }
    }

    isolated resource function get phone() returns int?|error {
        lock {
            return self.supplier.phone;
        }
    }

    isolated resource function get email() returns string?|error {
        lock {
            return self.supplier.email;
        }
    }

    isolated resource function get address() returns AddressData|error? {
        int id = 0;
        lock {
            id = self.supplier.address_id ?: 0;
            if( id == 0) {
                return null; // no point in querying if address id is null
            } 
        }
        
        return new AddressData(id);
    }

    isolated resource function get created() returns string?|error {
        lock {
            return self.supplier.created;
        }
    }

    isolated resource function get updated() returns string?|error {
        lock {
            return self.supplier.updated;
        }
    } 
    
}

