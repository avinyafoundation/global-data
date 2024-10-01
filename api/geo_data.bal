public isolated  service class GeoData {
    isolated resource function get province(string name) returns ProvinceData|error {
        lock {
            return new (name, ());
        }
        
    }

    isolated resource function get district(string name) returns DistrictData|error {
        return new (name, ());
    }

    isolated resource function get city(string name) returns CityData|error {
        return new (name, ());
    }

    isolated resource function get address(int id) returns AddressData|error {
        return new (id);
    }
}

public isolated service class ProvinceData {
    private Province province;

    isolated function init(string? name, int? province_id) returns error? {
        // NOTE: Change this to `AND` check once `sql:ParameterQuery` is fixed
       
        lock {
             Province province_raw = check db_client->queryRow(
                `SELECT *
                FROM province
                WHERE
                    id = ${province_id}
                    OR name_en = ${name};`
            );
        
            self.province = province_raw.cloneReadOnly();
        }
    }

    isolated resource function get id() returns int? {
        lock {
            return self.province.id;
        }
    }

    isolated resource function get name() returns LocalizedName {
        lock {
            return {
                "name_en": self.province["name_en"],
                "name_si": <string>self.province["name_si"],
                "name_ta": <string>self.province["name_ta"]
            };
        }
        
    }

    isolated resource function get districts() returns DistrictData[]|error {
        DistrictData[] districts = [];
        int? id = 0;
        lock {
            id = self.province.id;
        }

        stream<District, error?> candidate_districts = db_client->query(
            `SELECT district.id
            FROM district
            RIGHT JOIN province
            ON district.province_id = province.id
            WHERE province.id = ${id};`
        );
        // Build and add DistrictData to list; raise error if we encounter
        check from District d in candidate_districts
            do {
                DistrictData|error candidate_dd = new DistrictData((), d.id);
                if !(candidate_dd is error) {
                    districts.push(candidate_dd);
                }
            };
        // Close results stream
        check candidate_districts.close();

        return districts;
    }
}

public isolated  service class DistrictData {
    private District district;

    isolated function init(string? name, int? district_id,District? district = null) returns error? {

        if (district != null) {
            self.district = district.cloneReadOnly();
            return;
        }


        District district_raw = check db_client->queryRow(
            `SELECT *
            FROM district
            WHERE
                id = ${district_id}
                OR name_en = ${name};`
        );

        self.district = district_raw.cloneReadOnly();
    }

    isolated resource function get name() returns LocalizedName {
        lock {
            return {
                "name_en": self.district["name_en"],
                "name_si": <string>self.district["name_si"],
                "name_ta": <string>self.district["name_ta"]
            };
        }
    }

    isolated resource function get id() returns int? {
        lock {
            return self.district.id;
        }
    }

    isolated resource function get province() returns ProvinceData|error {
        lock {
            return new ((), self.district.province_id);
        }
    }

    isolated resource function get cities() returns CityData[]|error {
        CityData[] cities = [];
        int? id = 0;
        lock {
            id = self.district.id;
        }

        stream<City, error?> candidate_cities = db_client->query(
            `SELECT city.id
            FROM city
            RIGHT JOIN district
            ON city.district_id = district.id
            WHERE district.id = ${id};`
        );
        // Build and add CityData to list; raise error if we encounter
        check from City c in candidate_cities
            do {
                CityData|error candidate_cd = new CityData((), c.id);
                if !(candidate_cd is error) {
                    cities.push(candidate_cd);
                }
            };
        // Close results stream
        check candidate_cities.close();

        return cities;
    }
}

public isolated service class CityData {
    private City city;

    isolated function init(string? name, int? city_id) returns error? {
        City city_raw = check db_client->queryRow(
            `SELECT *
            FROM city
            WHERE
                id = ${city_id}
                OR name_en = ${name};`
        );

        self.city = city_raw.cloneReadOnly();
    }

    isolated  resource function get name() returns LocalizedName {
        lock {
            return {
                "name_en": self.city["name_en"],
                "name_si": <string>self.city["name_si"],
                "name_ta": <string>self.city["name_ta"]
            };
        }
    }

    isolated resource function get id() returns int? {
        lock {
            return self.city.id;
        }
    }

    isolated resource function get district() returns DistrictData|error {
        lock {
            return new ((), self.city.district_id);
        }
    }
}


public isolated service class AddressData {
    private Address address;

    isolated function init(int address_id) returns error? {
        Address address_raw = check db_client -> queryRow(
            `SELECT *
            FROM address
            WHERE id = ${address_id};`
        );

        self.address = address_raw.cloneReadOnly();
    }

    isolated resource function get city() returns CityData|error {
        lock {
            return new ((), self.address.city_id);
        }
    }

    isolated resource function get street_address() returns string? {
        lock {
            return self.address.street_address;
        }
    }

    isolated resource function get phone() returns int? {
        lock {
            return self.address.phone;
        }
    }

    isolated resource function get id() returns int? {
        lock {
            return self.address.id;
        }
    }
}
