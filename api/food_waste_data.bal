public isolated service class FoodWasteData {
    private FoodWaste food_waste;

    isolated function init(int? id = 0, FoodWaste? food_waste = null) returns error? {
        if (food_waste != null) {
            self.food_waste = food_waste.cloneReadOnly();
            return;
        }

        lock {
            FoodWaste food_waste_raw = check db_client->queryRow(
                `SELECT * FROM food_waste WHERE id = ${id}`
            );
            self.food_waste = food_waste_raw.cloneReadOnly();
        }
    }

    isolated resource function get id() returns int? {
        lock {
            return self.food_waste.id;
        }
    }

    isolated resource function get meal_serving_id() returns int {
        lock {
            return self.food_waste.meal_serving_id;
        }
    }

    isolated resource function get food_item_id() returns int {
        lock {
            return self.food_waste.food_item_id;
        }
    }

    isolated resource function get wasted_portions() returns int {
        lock {
            return self.food_waste.wasted_portions;
        }
    }

    isolated resource function get created() returns string? {
        lock {
            return self.food_waste.created;
        }
    }

    isolated resource function get updated() returns string? {
        lock {
            return self.food_waste.updated;
        }
    }

    isolated resource function get food_item() returns FoodItemData|error {
        int foodId;
        lock {
            foodId = self.food_waste.food_item_id;
        }
        return new FoodItemData(foodId, ());
    }

    isolated resource function get meal_serving() returns MealServingData|error {
        int mealServingId;
        lock {
            mealServingId = self.food_waste.meal_serving_id;
        }
        return new MealServingData(mealServingId, ());
    }
}