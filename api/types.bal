# Localized names in English, Sinhala, and Tamil.
# Names are stored with a `name_` prefix, followed
# by the respective ISO 639-1 language code.
#
# This record requires an English name, `name_en`.
#
# + name_en - Name in English
# + name_ta - Name in Tamil, தமிழ்
# + name_si - Name in Sinhala, සිංහල
public type LocalizedName record {
    string name_en;
    string? name_ta;
    string? name_si;
};

type GeospatialInformation record {|
    decimal latitude;
    decimal longitude;
|};

public type Province record {|
    readonly string record_type = "province";
    int id?;
    *LocalizedName;
|};

public type District record {|
    readonly string record_type = "district";
    int id?;
    int province_id?;
    *LocalizedName;
|};

public type City record {|
    readonly string record_type = "city";
    int id?;
    int district_id?;
    *LocalizedName;
    string suburb_name_en;
    string suburb_name_ta;
    string suburb_name_si;
    string postcode;
    *GeospatialInformation;
|};


public type Address record {
    readonly string record_type = "address";
    int id?;
    *LocalizedName;
    string street_address;
    int? phone;
    int city_id;
};

public type AvinyaType record{|
    readonly string record_type = "avinya_type";
    int id?;
    boolean active;
    string? global_type;
    string? name;
    string? foundation_type;
    string? focus;
    int? level;
|};

public type Organization record {|
    readonly string record_type = "organization";
    int id?;
    *LocalizedName;
    int[] child_organizations?;
    int[] parent_organizations?;
    int? address_id;
    int? avinya_type;
    int? phone;
|};

type ParentChildOrganization record {|
    int child_org_id;
    int parent_org_id;
|};

public type Person record {|
    readonly string record_type = "person";
    int id?;
    string? preferred_name;
    string? full_name;
    string? date_of_birth;
    string? sex;
    string? asgardeo_id;
    int? permanent_address_id;
    int? mailing_address_id;
    int? phone;
    int? organization_id;
    int? avinya_type_id;
    string? notes;
    string? nic_no;
    string? passport_no;
    string? id_no;
    string? email;
|};
