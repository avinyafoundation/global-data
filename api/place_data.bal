public isolated service class PlaceData {
    private Place place;

    isolated function init(string? name = null, int? place_id = 0, Place? place = null) returns error? {
        if(place != null) { // if place is provided, then use that and do not load from DB
            self.place = place.cloneReadOnly();
            return;
        }

        string _name = "%" + (name ?: "") + "%";
        int id = place_id ?: 0;

        Place place_raw;
        if(id > 0) { // place_id provided, give precedance to that
            place_raw = check db_client -> queryRow(
            `SELECT *
            FROM avinya_db.place
            WHERE
                id = ${id};`);
        } else 
        {
            place_raw = check db_client -> queryRow(
            `SELECT *
            FROM avinya_db.place
            WHERE
                name_en LIKE ${_name};`);
        }
        
        self.place = place_raw.cloneReadOnly();
    }

    isolated resource function get id() returns int? {
        lock {
                return self.place.id;
        }
    }

    isolated resource function get name() returns string? {
        lock {
                return self.place.name;
        }
    }

    isolated resource function get description() returns string? {
        lock {
                return self.place.description;
        }
    }

    isolated resource function get notes() returns string? {
        lock {
            return self.place.notes;
        }
    }

    isolated resource function get display_name() returns string? {
        lock {
            return self.place.display_name;
        }
    }

    isolated resource function get street_address() returns string? {
        lock {
            return self.place.street_address;
        }
    }

    isolated resource function get city() returns CityData|error? {
        lock {
            if(self.place.city_id == 0) {
                return ();
            }
            return check new CityData((), self.place.city_id);
        }
    }

    isolated resource function get suite() returns string? {
        lock {
            return self.place.suite;
        }
    }

    isolated resource function get level() returns int? {
        lock {
            return self.place.level;
        }
    }

    isolated resource function get address() returns AddressData|error? {
        int id = 0;
        lock {
            id = self.place.address_id ?: 0;
            if( id == 0) {
                return null; // no point in querying if address id is null
            } 
        }
        
        return new AddressData(id);
    }
    
    isolated resource function get created() returns string? {
        lock {
            return self.place.created;
        }
    }

    isolated resource function get updated() returns string? {
        lock {
            return self.place.updated;
        }
    }

    isolated resource function get child_activities() returns PlaceData[]|error? {
        // Get list of child places
        stream<ParentChildPlace, error?> child_place_ids;
        lock {
            child_place_ids = db_client->query(
                `SELECT *
                FROM avinya_db.parent_child_place
                WHERE parent_place_id = ${self.place.id}`
            );
        }

        PlaceData[] child_places = [];

        check from ParentChildPlace pc_place in child_place_ids
            do {
                PlaceData|error candidate_place = new PlaceData((), pc_place.child_place_id);
                if !(candidate_place is error) {
                    child_places.push(candidate_place);
                }
            };
        check child_place_ids.close();
        return child_places;
    }

    isolated resource function get parent_places() returns PlaceData[]|error? {
        // Get list of child places
        stream<ParentChildPlace, error?> parent_place_ids;
        lock {
            parent_place_ids = db_client->query(
                `SELECT *
                FROM avinya_db.parent_child_place
                WHERE child_place_id = ${self.place.id}`
            );
        }

        PlaceData[] parent_places = [];

        check from ParentChildPlace pc_place in parent_place_ids
            do {
                PlaceData|error candidate_place = new PlaceData((), pc_place.parent_place_id);
                if !(candidate_place is error) {
                    parent_places.push(candidate_place);
                }
            };
        check parent_place_ids.close();
        return parent_places;
    }    
    
}
