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
    readonly string? record_type = "province";
    int id?;
    *LocalizedName;
|};

public type District record {|
    readonly string? record_type = "district";
    int id?;
    int province_id?;
    *LocalizedName;
|};

public type City record {|
    readonly string? record_type = "city";
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
    readonly string? record_type = "address";
    int id?;
    *LocalizedName;
    string street_address;
    int? phone;
    int city_id;
};

public type AvinyaType record{|
    readonly string? record_type = "avinya_type";
    int id?;
    boolean active;
    string global_type;
    string? name;
    string? foundation_type;
    string? focus;
    int? level;
|};

public type Organization record {|
    readonly string? record_type = "organization";
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
    readonly string? record_type = "person";
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

public type EvaluationCycle record {|
    readonly string? record_type = "evaluation_cycle";
    int id?;
    string? name;
    string? description;
    string? start_date;
    string? end_date;
|};


public type EvaluationCriteria record {|
    readonly string? record_type = "evaluation_criteria";
    int id?;
    string? prompt;
    string? description;
    string? expected_answer;
    string? evalualtion_type;
    string? difficulty;
    int? rating_out_of;
|};

public type EvaluationCriteriaAnswerOption record {|
    readonly string? record_type = "evaluation_criteria_answer_option";
    int id?;
    int? evaluation_criteria_id;
    string? answer;
    boolean? expected_answer;
|};

public type Vacancy record {|
    readonly string? record_type = "vacancy";
    int id?;
    string? name;
    string? description;
    int? organization_id;
    int? avinya_type_id;
    int? evaluation_cycle_id;
    int? head_count;
|};

public type VacancyEvaluationCriteria record{|
    readonly string? record_type = "vacancy_evaluation_criteria";
    int? vacancy_id;
    int? evaluation_criteria_id;
|};

public type Application record{|
    readonly string? record_type = "application";
    int id?;
    int? person_id;
    int? vacancy_id;
    string? application_date;
|};

public type ApplicationStatus record{|
    readonly string? record_type = "application_status";
    int id?;
    int? application_id;
    string? status;
    string? updated;
    boolean? is_terminal;
|};

public type Evaluation record {|
    readonly string? record_type = "evaluation";
    int id?;
    int? evaluatee_id;
    int? evaluator_id;
    int? evaluation_criteria_id;
    string? updated;
    string? notes;
    int? grade;
|};

public type Metadata record {|
    readonly string? record_type = "metadata";
    int id?;
    int? evaluation_id;
    string? location;
    string? on_date_time;
    int? level;
    string? meta_type;
    string? focus;
    string? status;
    string? metadata;
    boolean? is_terminal;
|};

public type ParentChildEvaluation record {|
    readonly string? record_type = "parent_child_evaluation";
    int? child_evaluation_id;
    int? parent_evaluation_id;
|};

public type EducationExperience record {|
    readonly string? record_type = "education_experience";
    int id?;
    int? person_id;
    string? school;
    string? start_date;
    string? end_date;
|};

public type EducationExperienceEvaluation record {|
    readonly string? record_type = "education_experience_evaluation";
    int? education_experience_id;
    int? evaluation_id;
|};

public type WorkExperience record {|
    readonly string? record_type = "work_experience";
    int id?;
    int? person_id;
    string? organization;
    string? start_date;
    string? end_date;
|};

public type WorkExperienceEvaluation record {|
    readonly string? record_type = "work_experience_evaluation";
    int? work_experience_id;
    int? evaluation_id;
|};

public type ApplicantConsent record {|
    readonly string? record_type = "applicant_consent";
    int id?;
    int? organization_id;
    int? avinya_type_id;
    int? person_id;
    int? application_id;
    string? name;
    string? date_of_birth;
    boolean? done_ol;
    int? ol_year;
    int? distance_to_school;
    int? phone;
    string? email;
    boolean? information_correct_consent;
    boolean? agree_terms_consent;
    string? created;
|};

public type Prospect record {|
    readonly string? record_type = "prospect";
    int id?;
    string? name;
    int? phone;
    string? email;
    boolean? receive_information_consent;
    boolean? agree_terms_consent;
    string? created;
|};
