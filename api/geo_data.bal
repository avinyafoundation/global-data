public distinct service class GeoData {
    resource function get province(string name) returns ProvinceData|error {
        return new (name, ());
    }

    resource function get district(string name) returns DistrictData|error {
        return new (name, ());
    }

    resource function get city(string name) returns CityData|error {
        return new (name, ());
    }

    resource function get address(int id) returns AddressData|error {
        return new (id);
    }
}

public distinct service class ProvinceData {
    private Province province;

    function init(string? name, int? province_id) returns error? {
        // NOTE: Change this to `AND` check once `sql:ParameterQuery` is fixed
        Province province_raw = check db_client->queryRow(
            `SELECT *
            FROM avinya_db.province
            WHERE
                id = ${province_id}
                OR name_en = ${name};`
        );

        self.province = province_raw;
    }

    resource function get id() returns int? {
        return self.province.id;
    }

    resource function get name() returns LocalizedName {
        return {
            "name_en": self.province["name_en"],
            "name_si": <string>self.province["name_si"],
            "name_ta": <string>self.province["name_ta"]
        };
    }

    resource function get districts() returns DistrictData[]|error {
        DistrictData[] districts = [];

        stream<District, error?> candidate_districts = db_client->query(
            `SELECT district.id
            FROM avinya_db.district
            RIGHT JOIN avinya_db.province
            ON avinya_db.district.province_id = avinya_db.province.id
            WHERE avinya_db.province.id = ${self.province.id};`
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

public distinct service class DistrictData {
    private District district;

    function init(string? name, int? district_id) returns error? {
        District district_raw = check db_client->queryRow(
            `SELECT *
            FROM avinya_db.district
            WHERE
                id = ${district_id}
                OR name_en = ${name};`
        );

        self.district = district_raw.cloneReadOnly();
    }

    resource function get name() returns LocalizedName {
        return {
            "name_en": self.district["name_en"],
            "name_si": <string>self.district["name_si"],
            "name_ta": <string>self.district["name_ta"]
        };
    }

    resource function get id() returns int? {
        return self.district.id;
    }

    resource function get province() returns ProvinceData|error {
        return new ((), self.district.province_id);
    }

    resource function get cities() returns CityData[]|error {
        CityData[] cities = [];

        stream<City, error?> candidate_cities = db_client->query(
            `SELECT city.id
            FROM avinya_db.city
            RIGHT JOIN avinya_db.district
            ON avinya_db.city.district_id = avinya_db.district.id
            WHERE avinya_db.district.id = ${self.district.id};`
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

public distinct service class CityData {
    private City city;

    function init(string? name, int? city_id) returns error? {
        City city_raw = check db_client->queryRow(
            `SELECT *
            FROM avinya_db.city
            WHERE
                id = ${city_id}
                OR name_en = ${name};`
        );

        self.city = city_raw.cloneReadOnly();
    }

    resource function get name() returns LocalizedName {
        return {
            "name_en": self.city["name_en"],
            "name_si": <string>self.city["name_si"],
            "name_ta": <string>self.city["name_ta"]
        };
    }

    resource function get id() returns int? {
        return self.city.id;
    }

    resource function get district() returns DistrictData|error {
        return new ((), self.city.district_id);
    }
}


public distinct service class AddressData {
    private Address address;

    function init(int address_id) returns error? {
        Address address_raw = check db_client -> queryRow(
            `SELECT *
            FROM avinya_db.address
            WHERE id = ${address_id};`
        );

        self.address = address_raw.cloneReadOnly();
    }

    resource function get city() returns CityData|error {
        return new ((), self.address.city_id);
    }

    resource function get street_address() returns string {
        return self.address.street_address;
    }

    resource function get phone() returns int? {
        return self.address.phone;
    }
}
