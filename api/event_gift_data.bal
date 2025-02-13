public isolated service class EventGiftData {

    private EventGift event_gift;

    isolated function init(int? id = 0, EventGift? eventGift = null) returns error? {

        if (eventGift != null) {
            self.event_gift = eventGift.cloneReadOnly();
            return;
        }

        lock {

            EventGift event_gift_raw;

            if (id > 0) {

                event_gift_raw = check db_client->queryRow(
                `SELECT *
                FROM event_gift
                WHERE id = ${id};`);

            } else {
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
}
