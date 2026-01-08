public isolated service class MaintenanceFinanceData {

    private MaintenanceFinance maintenance_finance;

    isolated function init(int? id = 0, int? activity_instance_id = 0, MaintenanceFinance? maintenanceFinance = null) returns error? {

        if (maintenanceFinance != null) {
            self.maintenance_finance = maintenanceFinance.cloneReadOnly();
            return;
        }

        lock {
            MaintenanceFinance maintenance_finance_raw;

            if (id > 0) {

                maintenance_finance_raw = check db_client->queryRow(
                `SELECT *
                FROM maintenance_finance
                WHERE id = ${id};`);

            } else if (activity_instance_id > 0) {

                maintenance_finance_raw = check db_client->queryRow(
                `SELECT *
                FROM maintenance_finance
                WHERE activity_instance_id = ${activity_instance_id};`);

            } else {
                return error("Invalid request : either id or activity instance id must be greater than 0");
            }

            self.maintenance_finance = maintenance_finance_raw.cloneReadOnly();

        }
    }

    isolated resource function get id() returns int?|error {
        lock {
            return self.maintenance_finance.id;
        }
    }

    isolated resource function get activity_instance_id() returns int?|error {
        lock {
            return self.maintenance_finance.activity_instance_id;
        }
    }

    isolated resource function get estimated_cost() returns decimal?|error {
        lock {
            return self.maintenance_finance.estimated_cost;
        }
    }

    isolated resource function get labour_cost() returns decimal?|error {
        lock {
            return self.maintenance_finance.labour_cost;
        }
    }

    //get material costs object
    isolated resource function get material_costs() returns MaterialCostData[]|error? {
        stream<MaterialCost, error?> materialCostsStream;
        lock {
            materialCostsStream = db_client->query(
                `SELECT *
                FROM material_cost
                WHERE financial_id = ${self.maintenance_finance.id}`
            );
        }

        MaterialCostData[] materialCostDatas = [];

        check from MaterialCost materialCost in materialCostsStream
            do {
                MaterialCostData|error materialCostData = new MaterialCostData((), materialCost);
                if !(materialCostData is error) {
                    materialCostDatas.push(materialCostData);
                }
            };

        check materialCostsStream.close();
        return materialCostDatas;
    }

    isolated resource function get status() returns string?|error {
        lock {
            return self.maintenance_finance.status;
        }
    }

    isolated resource function get rejection_reason() returns string?|error {
        lock {
            return self.maintenance_finance.rejection_reason;
        }
    }

    isolated resource function get reviewed_by() returns string?|error {
        lock {
            return self.maintenance_finance.reviewed_by;
        }
    }

    isolated resource function get reviewed_date() returns string?|error {
        lock {
            return self.maintenance_finance.reviewed_date;
        }
    }

    isolated resource function get created() returns string?|error {
        lock {
            return self.maintenance_finance.created;
        }
    }

    isolated resource function get updated() returns string?|error {
        lock {
            return self.maintenance_finance.updated;
        }
    }

}
