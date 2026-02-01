public isolated service class MaterialCostData {

    private MaterialCost material_cost;

    isolated function init(int? id = 0, MaterialCost? materialCost = null) returns error? {

        if (materialCost != null) {
            self.material_cost = materialCost.cloneReadOnly();
            return;
        }

        lock {
            MaterialCost material_cost_raw;

            if (id > 0) {

                material_cost_raw = check db_client->queryRow(
                `SELECT *
                FROM material_cost
                WHERE id = ${id};`);

            }else {
                return error("Invalid request : id must be greater than 0");
            }

            self.material_cost = material_cost_raw.cloneReadOnly();

        }
    }

    isolated resource function get id() returns int?|error {
        lock {
            return self.material_cost.id;
        }
    }

    isolated resource function get financial_id() returns int?|error {
        lock {
            return self.material_cost.financial_id;
        }
    }

    isolated resource function get item() returns string?|error {
        lock {
            return self.material_cost.item;
        }
    }

    isolated resource function get quantity() returns decimal?|error {
        lock {
            return self.material_cost.quantity;
        }
    }

    isolated resource function get unit() returns string?|error {
        lock {
            return self.material_cost.unit;
        }
    }

    isolated resource function get unit_cost() returns decimal?|error {
        lock {
            return self.material_cost.unit_cost;
        }
    }

}
