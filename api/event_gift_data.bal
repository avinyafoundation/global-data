public isolated service class EventGiftData {

    private EventGift event_gift = {
        activity_instance_id: -1,
        gift_amount: -1,
        no_of_gifts: -1,
        notes: "",
        description: ""
    };

    isolated function init(int? id = 0,int? activity_instance_id = 0, EventGift? eventGift = null) returns error? {

        if (eventGift != null) {
            self.event_gift = eventGift.cloneReadOnly();
            return;
        }

        lock {

            EventGift event_gift_raw;

            if (id > 0) {

                event_gift_raw =  check db_client->queryRow(
                `SELECT *
                FROM event_gift
                WHERE id = ${id};`);

            }else if(activity_instance_id > 0) {
                
                event_gift_raw =  check db_client->queryRow(
                `SELECT *
                FROM event_gift
                WHERE activity_instance_id = ${activity_instance_id};`);

            }else {
                return error("No id provided");
            }

            self.event_gift = event_gift_raw.cloneReadOnly();

        }

    }

    isolated resource function get id() returns int?|error {
        lock {
            return self.event_gift.id;
        }
    }

    isolated resource function get activity_instance_id() returns int?|error {
        lock {
            return self.event_gift.activity_instance_id;
        }
    }

    isolated resource function get gift_amount() returns decimal?|error {
        lock {
            return self.event_gift.gift_amount;
        }
    }

    isolated resource function get no_of_gifts() returns int?|error {
        lock {
            return self.event_gift.no_of_gifts;
        }
    }

    isolated resource function get notes() returns string?|error {
        lock {
            return self.event_gift.notes;
        }
    }

    isolated resource function get description() returns string?|error {
        lock {
            return self.event_gift.description;
        }
    }
}
