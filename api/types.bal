

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
    string? name_en;
    string? name_ta;
    string? name_si;
};

type GeospatialInformation record {|
    decimal? latitude;
    decimal? longitude;
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
    string? suburb_name_en;
    string? suburb_name_ta;
    string? suburb_name_si;
    string? postcode;
    *GeospatialInformation;
|};

public type Address record {
    readonly string? record_type = "address";
    int id?;
    //*LocalizedName;
    string? street_address;
    int? phone;
    int? city_id;
    City? city;
};

public type AvinyaType record {|
    readonly string? record_type = "avinya_type";
    int id?;
    boolean active;
    string global_type;
    string? name;
    string? description;
    string? foundation_type;
    string? focus;
    int? level;
|};

public type Reference record {|
    readonly string? record_type = "reference";
    int id?;
    int last_reference_no;
    int batch_no;
    string? branch_code;
    string foundation_type;
    string acedemic_year;
|};

public type Organization record {|
    readonly string? record_type = "organization";
    int id?;
    *LocalizedName;
    int[] child_organizations?;
    int[] parent_organizations?;
    int[] child_organizations_for_dashboard?;
    int? address_id;
    int? avinya_type;
    int? phone;
    string? description;
    string? notes;
    int? active;
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
    string? jwt_sub_id;
    string? jwt_email;
    int? permanent_address_id;
    int? mailing_address_id;
    int? phone;
    int? organization_id;
    int? parent_organization_id;
    int? avinya_type_id;
    string? notes;
    string? nic_no;
    string? passport_no;
    string? id_no;
    string? email;
    Address? permanent_address;
    Address? mailing_address;
    string? created;
    string? updated;
    int[] child_student?;
    int[] parent_student?;
    string? street_address;
    string? digital_id;
    int? avinya_phone;
    string? bank_name;
    string? bank_branch;
    string? bank_account_number;
    string? bank_account_name;
    int? academy_org_id;
    string? academy_org_name;
    string? branch_code;
    string? current_job;
    int? documents_id;
    int? created_by;
    int? updated_by;
|};

type ParentChildStudent record {|
    int child_student_id;
    int parent_student_id;
|};

type PersonAvinyaTypeTransitionHistory record {|
    readonly string? record_type = "person_avinya_type_transition_history";
    int? id;
    int? person_id;
    int? previous_avinya_type_id;
    int? new_avinya_type_id;
    string? transition_date;
    string? created;
    string? updated;
|};

type PersonOrganizationTransitionHistory record {|
    readonly string? record_type = "person_organization_transition_history";
    int? id;
    int? person_id;
    int? previous_organization_id;
    int? new_organization_id;
    string? transition_date;
    string? created;
    string? updated;
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
    string? evaluation_type;
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

public type VacancyEvaluationCriteria record {|
    readonly string? record_type = "vacancy_evaluation_criteria";
    int? vacancy_id;
    int? evaluation_criteria_id;
|};

public type Application record {|
    readonly string? record_type = "application";
    int id?;
    int? person_id;
    int? vacancy_id;
    string? application_date;
|};

public type ApplicationStatus record {|
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
    int? activity_instance_id;
    string? updated;
    string? created;
    string? response;
    string? notes;
    int? grade;
    int[] child_evaluations?;
    int[] parent_evaluations?;
|};

public type EvaluationMetadata record {|
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
    int[] evaluation_id?;
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
    int[] evaluation_id?;
|};

public type WorkExperienceEvaluation record {|
    readonly string? record_type = "work_experience_evaluation";
    int? work_experience_id;
    int? evaluation_id;
|};

public type ApplicantConsent record {|
    readonly string? record_type = "applicant_consent";
    int id?;
    boolean? active;
    int? organization_id;
    int? avinya_type_id;
    int? person_id;
    int? application_id;
    string? name;
    string? date_of_birth;
    string? done_ol;
    int? ol_year;
    string? done_al;
    int? al_year;
    string? al_stream;
    int? distance_to_school;
    int? phone;
    string? email;
    boolean? information_correct_consent;
    boolean? agree_terms_consent;
    string? created;
    string? updated;
|};

public type Prospect record {|
    readonly string? record_type = "prospect";
    int id?;
    boolean? active;
    string? name;
    int? phone;
    string? email;
    boolean? receive_information_consent;
    boolean? agree_terms_consent;
    string? created;
    string? updated;
    string? street_address;
    string? date_of_birth;
    boolean? done_ol;
    int? ol_year;
    int? distance_to_school;
    boolean? verified;
    boolean? contacted;
    boolean? applied;
|};

public type Activity record {|
    readonly string? record_type = "activity";
    int id?;
    string? name;
    string? description;
    int? avinya_type_id;
    string? notes;
    string? created;
    string? updated;
    int[] child_activities?;
    int[] parent_activities?;
|};

public type ActivitySequencePlan record {|
    readonly string? record_type = "activity_sequence_plan";
    int id?;
    int? activity_id;
    int? sequence_number;
    int? timeslot_number;
    int? person_id;
    int? organization_id;
    string? created;
    string? updated;
|};

public type ParentChildActivity record {|
    readonly string? record_type = "parent_child_activity";
    int? child_activity_id;
    int? parent_activity_id;
|};

public type Place record {|
    readonly string? record_type = "place";
    int id?;
    string? olc;
    int? city_id;
    string? name;
    string? display_name;
    string? street_address;
    string? suite;
    int? level;
    int? address_id;
    string? description;
    string? notes;
    string? created;
    string? updated;
|};

public type ParentChildPlace record {|
    readonly string? record_type = "parent_child_place";
    int? child_place_id;
    int? parent_place_id;
|};

public type ActivityInstance record {|
    readonly string? record_type = "activity_instance";
    int id?;
    int? activity_id;
    string? name;
    int? place_id;
    int? organization_id;
    int? daily_sequence;
    int? weekly_sequence;
    int? monthly_sequence;
    string? description;
    string? notes;
    string? start_time;
    string? end_time;
    string? created;
    string? updated;
|};

public type ActivityParticipant record {|
    readonly string? record_type = "activity_participant";
    int id?;
    int? activity_instance_id;
    int? person_id;
    int? organization_id;
    string? start_date;
    string? end_date;
    string? role;
    string? notes;
    string? created;
    string? updated;
|};

public type ActivityParticipantAttendance record {|
    readonly string? record_type = "activity_participant_attendance";
    int id?;
    int? person_id;
    int? activity_instance_id;
    string? sign_in_time;
    string? sign_out_time;
    string? in_marked_by;
    string? out_marked_by;
    string? created;
    string? updated;
|};

public type AttendanceDashboardData record {|
    readonly string? record_type = "attendance_dashboard_data";
    string? title;
    int? numOfFiles;
    string? svgSrc;
    string? color;
    decimal? percentage;
|};

public type AttendanceDashboardDataForQuery record {|
    readonly string? record_type = "attendance_dashboard_data_for_query";
    int? present_count;
    int? absent_count;
    int? late_attendance;
    int? present_count_duty;
    int? absent_count_duty;
    int? late_attendance_duty;
    float? total_students;
|};

public type AttendanceDashboardDataMain record {|
    readonly string? record_type = "attendance_dashboard_data_main";
    AttendanceDashboardData? attendance_dashboard_data;
|};


public type ActivityParticipantAttendanceForLateAttendance record {|
    readonly string? record_type = "activity_participant_attendance";
    int id?;
    int? person_id;
    int? activity_instance_id;
    string? sign_in_time;
    string? sign_out_time;
    string? in_marked_by;
    string? out_marked_by;
    string? created;
    string? updated;
    string? description;
    string? preferred_name;
    string? digital_id;
|};

public type ActivityParticipantAttendanceSummaryReport record {|
    readonly string? record_type = "activity_participant_attendance_summary_report";
    string? sign_in_date;
    int? present_count;
    int? late_count;
    int? total_count;
    decimal? present_attendance_percentage;
    decimal? late_attendance_percentage;
|};

public type ActivityParticipantAttendanceMissedBySecurity record {|
    readonly string? record_type = "activity_participant_attendance_missed_by_security";
    string? sign_in_time;
    string? preferred_name;
    string? digital_id;
    string? description;
|};

public type DailyActivityParticipantAttendanceByParentOrg record {|
    readonly string? record_type = "daily_activity_participant_attendance_by_parent_org";
    string? description;
    int? present_count;
    string? svg_src;
    string? color;
    int? total_student_count;
|};

public type TotalActivityParticipantAttendanceCountByDate record {|
    readonly string? record_type = "total_activity_participant_attendance_count_by_date";
    string? attendance_date;
    int? daily_total;
|};


public type ActivityEvaluationCriteria record {|
    readonly string? record_type = "activity_evaluation_criteria";
    int? activity_id;
    int? evaluation_criteria_id;
|};

public type ActivityInstanceEvaluationCriteria record {|
    readonly string? record_type = "activity_instance_evaluation_criteria";
    int? activity_instance_id;
    int? evaluation_criteria_id;
|};

public type Asset record {|
    readonly string? record_type = "asset";
    int id?;
    string? name;
    string? manufacturer;
    string? model;
    string? serial_number;
    string? registration_number;
    string? description;
    int? avinya_type_id;
    string? created;
    string? updated;
|};

public type Supplier record {|
    readonly string? record_type = "supplier";
    int id?;
    string? name;
    string? description;
    int? phone;
    string? email;
    int? address_id;
    string? created;
    string? updated;
|};

public type Consumable record {|
    readonly string? record_type = "consumable";
    int id?;
    int? avinya_type_id;
    string? name;
    string? description;
    string? manufacturer;
    string? model;
    string? serial_number;
    decimal? threshold;
    string? created;
    string? updated;
|};

public type ResourceProperty record {|
    readonly string? record_type = "resource_property";
    int id?;
    int? asset_id;
    int? consumable_id;
    string? property;
    string? value;
|};

public type Supply record {|
    readonly string? record_type = "supply";
    int id?;
    int? asset_id;
    int? consumable_id;
    int? supplier_id;
    int? person_id;
    string? order_date;
    string? delivery_date;
    string? order_id;
    int? order_amount;
    string? created;
    string? updated;
|};

public type ResourceAllocation record {|
    readonly string? record_type = "resource_allocation";
    int id?;
    boolean? requested;
    boolean? approved;
    boolean? allocated;
    int? asset_id;
    int? consumable_id;
    int? organization_id;
    int? person_id;
    int? quantity;
    string? start_date;
    string? end_date;
    string? created;
    string? updated;
    ResourceProperty[] resource_properties?;
|};

public type Inventory record {|
    readonly string? record_type = "inventory";
    int id?;
    int? avinya_type_id;
    int? asset_id;
    int? consumable_id;
    string? name;
    string? month_name;
    string? description;
    string? manufacturer;
    int? organization_id;
    int? person_id;
    decimal? quantity;
    decimal? quantity_in;
    decimal? quantity_out;
    decimal? prev_quantity;
    int? resource_property_id;
    string? resource_property_value;
    int? is_below_threshold;
    string? created;
    string? updated;
|};

public type DutyParticipant record{|
    readonly string? record_type = "duty_participant";
    int id?;
    int? activity_id;
    Activity? activity;
    int? person_id;
    Person? person;
    string? role;
    string? created;
    string? updated;

|};

public type DutyRotationMetaDetails record{|
    readonly string? record_type = "duty_rotation_metadata";
    int id?;
    string? start_date;
    string? end_date;
    int? organization_id;
|};

public type OrganizationMetaDataDetails record{|
    readonly string?  record_type = "organization_metadata";
    int id?;
    int? organization_id;
    string? key_name;
    string? value;
|};

public type Vehicle record{|
    readonly string?  record_type = "vehicle";
    int id?;
    string? vehicle_number;
    int? organization_id;
    int? person_id;
    string? created;
    string? updated;
|};

public type VehicleReasonMetadata record{|
    readonly string?  record_type = "vehicle_reason_metadata";
    int id?;
    string? reason;
    string? created;
|};

public type VehicleFuelConsumption record{|
    readonly string? record_type = "vehicle_fuel_consumption";
    int id?;
    int? vehicle_id;
    string? date_time;
    int? reason_id;
    string? starting_meter;
    string? ending_meter;
    string? distance;
    string? comment;
    string? created;
    string? updated;
|};

public type CalendarMetadata record {|
    readonly string? record_type = "calendar_metadata";
    int id?;
    int? organization_id;
    decimal? monthly_payment_amount;
|};

public type MonthlyLeaveDates record {|
    readonly string? record_type = "monthly_leave_dates";
    int id?;
    int? year;
    int? month;
    int? total_days_in_month;
    int? organization_id;
    int[] leave_dates_list;
    string? leave_dates;
    decimal? daily_amount;
    string? created;
    string? updated;
|};

public type UserDocument record {|
    readonly string? record_type = "user_document";
    int id?;
    string? folder_id;
    string? nic_front_id;
    string? nic_back_id;
    string? birth_certificate_front_id;
    string? birth_certificate_back_id;
    string? ol_certificate_id;
    string? al_certificate_id;
    string? additional_certificate_01_id;
    string? additional_certificate_02_id;
    string? additional_certificate_03_id;
    string? additional_certificate_04_id;
    string? additional_certificate_05_id;
    string? document_type;
    string? document;
|};

public type OrganizationFolderMapping record {|
    readonly string? record_type = "organization_folder_mapping";
    int id?;
    int? organization_id;
    string? organization_folder_id;
|};

public type ErrorDetail record {|
    string message;
    int errorCode;
|};
