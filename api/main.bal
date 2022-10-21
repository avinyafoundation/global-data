import ballerina/graphql;
import ballerina/sql;

service graphql:Service /graphql on new graphql:Listener(4000) {
    resource function get geo() returns GeoData {
        return new ();
    }

    isolated resource function get organization_structure(string? name, int? id) returns OrganizationStructureData|error? {
        return new (name, id);
    }

    isolated resource function get organizations(int level) returns OrganizationStructureData|error? {
        return new (level = level);
    }

    isolated resource function get organization(string? name, int? id) returns OrganizationData|error? {
        return new (name, id);
    }

    isolated resource function get applicant_consent(string? email, int? phone) returns ApplicantConsentData|error? {
        return new (email, phone);
    }


    remote function  add_student_applicant(Person person) returns PersonData|error? {
        
        AvinyaType avinya_type_raw = check db_client -> queryRow(
            `SELECT *
            FROM avinya_db.avinya_type
            WHERE global_type = "applicant" AND  foundation_type = "student";`
        );
        
        sql:ExecutionResult res = check db_client->execute(
            `INSERT INTO avinya_db.person (
                preferred_name,
                full_name,
                sex,
                organization_id,
                phone,
                email,
                avinya_type_id
            ) VALUES (
                ${person.preferred_name},
                ${person.full_name},
                ${person.sex},
                ${person.organization_id},
                ${person.phone},
                ${person.email},
                ${avinya_type_raw.id}
            );`
        );

        int|string? insert_id = res.lastInsertId;
        if !(insert_id is int) {
            return error("Unable to insert person");
        }

        return new((), insert_id);
    }

    remote function  add_student_applicant_consent(ApplicantConsent applicantConsent) returns ApplicantConsentData|error? {
        
        ApplicantConsent|error? applicantConsentRaw = db_client -> queryRow(
            `SELECT *
            FROM avinya_db.applicant_consent
            WHERE email = ${applicantConsent.email}  OR
            phone = ${applicantConsent.phone};`
        );
        
        if(applicantConsentRaw is ApplicantConsent) {
            return error("Applicant already exists. The phone or the email you provided is already used by another applicant");
        }

        sql:ExecutionResult res = check db_client->execute(
            `INSERT INTO avinya_db.applicant_consent (
                name,
                date_of_birth,
                done_ol,
                ol_year,
                distance_to_school,
                phone,
                email,
                information_correct_consent,
                agree_terms_consent
            ) VALUES (
                ${applicantConsent.name},
                ${applicantConsent.date_of_birth},
                ${applicantConsent.done_ol},
                ${applicantConsent.ol_year},
                ${applicantConsent.distance_to_school},
                ${applicantConsent.phone},
                ${applicantConsent.email},
                ${applicantConsent.information_correct_consent},
                ${applicantConsent.agree_terms_consent}
            );`
        );

        

        int|string? insert_id = res.lastInsertId;
        if !(insert_id is int) {
            return error("Unable to insert applicant_consent");
        }

        return new(applicantConsent.email, applicantConsent.phone);
    }

    remote function add_address(Address address) returns AddressData|error? {
        sql:ExecutionResult res = check db_client->execute(
            `INSERT INTO avinya_db.address (
                street_address,
                phone,
                city_id
            ) VALUES (
                ${address.street_address},
                ${address.phone},
                ${address.city_id}
            );`
        );

        int|string? insert_id = res.lastInsertId;
        if !(insert_id is int) {
            return error("Unable to insert addresss");
        }

        return new(insert_id);
    }

    remote function add_prospect(Prospect prospect) returns ProspectData|error? {
        sql:ExecutionResult res = check db_client->execute(
            `INSERT INTO avinya_db.prospect (
                name,
                phone,
                email,
                receive_information_consent,
                agree_terms_consent
            ) VALUES (
                ${prospect.name},
                ${prospect.phone},
                ${prospect.email},
                ${prospect.receive_information_consent},
                ${prospect.agree_terms_consent}
            );`
        );

        int|string? insert_id = res.lastInsertId;
        if !(insert_id is int) {
            return error("Unable to insert addresss");
        }

        return new(prospect.email, prospect.phone);
    }

    remote function add_organization(Organization org) returns OrganizationData|error? {
        sql:ExecutionResult res = check db_client->execute(
            `INSERT INTO avinya_db.organization (
                name_en,
                name_si,
                name_ta,
                address_id,
                phone
            ) VALUES (
                ${org.name_en},
                ${org.name_si},
                ${org.name_ta},
                ${org.address_id},
                ${org.phone},
            );`
        );

        int|string? insert_id = res.lastInsertId;
        if !(insert_id is int) {
            return error("Unable to insert organization");
        }

        // Insert child and parent organization relationships
        int[] child_org_ids = org.child_organizations ?: [];
        int[] parent_org_ids = org.parent_organizations ?: [];

        foreach int child_idx in child_org_ids {
            _ = check db_client->execute(
                `INSERT INTO avinya_db.parent_child_organization (
                    child_org_id,
                    parent_org_id
                ) VALUES (
                    ${child_idx}, ${org.id}
                );` 
            );
        }

        foreach int parent_idx in parent_org_ids {
            _ = check db_client->execute(
                `INSERT INTO avinya_db.parent_child_organization (
                    child_org_id,
                    parent_org_id
                ) VALUES (
                    ${org.id}, ${parent_idx}
                );` 
            );
        }

        return new ((), insert_id);
    }
}
