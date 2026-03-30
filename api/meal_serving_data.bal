public isolated service class MealServingData {
    private MealServing meal_serving;

    isolated function init(int? id = 0, MealServing? meal_serving = null) returns error? {
        if (meal_serving != null) {
            self.meal_serving = meal_serving.cloneReadOnly();
            return;
        }

        lock {
            MealServing meal_serving_raw = check db_client->queryRow(
                `SELECT * FROM meal_serving WHERE id = ${id}`
            );
            self.meal_serving = meal_serving_raw.cloneReadOnly();
        }
    }

    isolated resource function get id() returns int? {
        lock {
            return self.meal_serving.id;
        }
    }

    isolated resource function get serving_date() returns string {
        lock {
            return self.meal_serving.serving_date;
        }
    }

    isolated resource function get meal_type() returns string {
        lock {
            return self.meal_serving.meal_type;
        }
    }

    isolated resource function get organization_id() returns int? {
        lock {
            return self.meal_serving.organization_id;
        }
    }

    isolated resource function get served_count() returns int {
        lock {
            return self.meal_serving.served_count;
        }
    }

    isolated resource function get notes() returns string? {
        lock {
            return self.meal_serving.notes;
        }
    }

    isolated resource function get created() returns string? {
        lock {
            return self.meal_serving.created;
        }
    }

    isolated resource function get updated() returns string? {
        lock {
            return self.meal_serving.updated;
        }
    }

    isolated resource function get food_wastes() returns FoodWasteData[]|error {
        int? mealServingId;
        lock {
            mealServingId = self.meal_serving.id;
        }
        
        stream<FoodWaste, error?> food_wastes = db_client->query(
            `SELECT * FROM food_waste WHERE meal_serving_id = ${mealServingId}`
        );
        
        FoodWasteData[] foodWasteDatas = [];
        check from FoodWaste item in food_wastes
            do {
                FoodWasteData|error foodWasteData = new FoodWasteData(0, item);
                if !(foodWasteData is error) {
                    foodWasteDatas.push(foodWasteData);
                }
            };
        
        check food_wastes.close();
        return foodWasteDatas;
    }
}