public isolated service class FoodItemData {
    private FoodItem food_item;

    isolated function init(int? id = 0, FoodItem? food_item = null) returns error? {
        if (food_item != null) {
            self.food_item = food_item.cloneReadOnly();
            return;
        }

        lock {
            FoodItem food_item_raw = check db_client->queryRow(
                `SELECT * FROM food_item WHERE id = ${id}`
            );
            self.food_item = food_item_raw.cloneReadOnly();
        }
    }

    isolated resource function get id() returns int? {
        lock {
            return self.food_item.id;
        }
    }

    isolated resource function get name() returns string {
        lock {
            return self.food_item.name;
        }
    }

    isolated resource function get cost_per_portion() returns decimal {
        lock {
            return self.food_item.cost_per_portion;
        }
    }

    isolated resource function get meal_type() returns string {
        lock {
            return self.food_item.meal_type;
        }
    }

    isolated resource function get created() returns string? {
        lock {
            return self.food_item.created;
        }
    }

    isolated resource function get updated() returns string? {
        lock {
            return self.food_item.updated;
        }
    }

    isolated resource function get is_deleted() returns int? {
        lock {
            return self.food_item.is_deleted;
        }
    }
}
