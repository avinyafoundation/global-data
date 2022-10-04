

public distinct service class PersonData {
    private Person person;

    isolated function init(string? name = null, int? person_id = 0, Person? person = null) returns error? {
        if(person != null) { // if person is provided, then use that and do not load from DB
            self.person = person.cloneReadOnly();
            return;
        }

        string _name = "%" + (name ?: "") + "%";
        int id = person_id ?: 0;

        Person person_raw;
        if(id > 0) { // organization_id provided, give precedance to that
            person_raw = check db_client -> queryRow(
            `SELECT *
            FROM avinya_db.person
            WHERE
                id = ${id};`);
        } else 
        {
            person_raw = check db_client -> queryRow(
            `SELECT *
            FROM avinya_db.person
            WHERE
                name_en LIKE ${_name};`);
        }
        
        self.person = person_raw.cloneReadOnly();

    }

    resource function get preferred_name() returns string?{
        return self.person.preferred_name;
    }

    resource function get full_name() returns string?{
        return self.person.full_name;
    }

    resource function get date_of_birth() returns string?{
        return self.person.date_of_birth;
    }

    resource function get sex() returns string?{
        return self.person.sex;
    }

    resource function get asgardeo_id() returns string?{
        return self.person.asgardeo_id;
    }

    isolated resource function get permanent_address() returns AddressData|error? {
        int id = self.person.permanent_address_id ?: 0;
        if( id == 0) {
            return null; // no point in querying if address id is null
        } 
        
        return new AddressData(id);
    }

    isolated resource function get mailing_address() returns AddressData|error? {
        int id = self.person.mailing_address_id ?: 0;
        if( id == 0) {
            return null; // no point in querying if address id is null
        } 
        
        return new AddressData(id);
    }

    resource function get phone() returns int? {
        return self.person.phone;
    }

    resource function get organization() returns OrganizationData|error? {
        int id = self.person.organization_id ?: 0;
        if(id == 0) {
            return null; // no point in querying if avinya type is null
        }
        return new OrganizationData((), id);
    }

    resource function get avinya_type() returns AvinyaTypeData|error? {
        int id = self.person.avinya_type_id ?: 0;
        if(id == 0) {
            return null; // no point in querying if avinya type is null
        }
        return new AvinyaTypeData(id);
    }

    resource function get notes() returns string?{
        return self.person.notes;
    }

    resource function get nic_no() returns string?{
        return self.person.nic_no;
    }

    resource function get passport_no() returns string?{
        return self.person.passport_no;
    }

    resource function get id_no() returns string?{
        return self.person.id_no;
    }

    resource function get email() returns string?{
        return self.person.email;
    }

}
