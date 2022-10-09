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

    remote function  add_student(Person person) returns PersonData|error? {
        
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
            return error("Unable to insert addresss");
        }

        return new((), insert_id);
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
