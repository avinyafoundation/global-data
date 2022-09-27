public type DistrictAndCityByProvinceResponse record {|
    map<json?> __extensions?;
    record {|
        record {|
            record {|
                string name_en;
            |} name;
            record {|
                record {|
                    string name_en;
                |} name;
                record {|
                    record {|
                        string name_en;
                    |} name;
                |}[] cities;
            |}[] districts;
        |} province;
    |} geo;
|};
