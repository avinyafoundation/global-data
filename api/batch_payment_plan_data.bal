public isolated service class BatchPaymentPlanData {

    private BatchPaymentPlan batch_payment_plan;

    isolated function init(int? id=0, BatchPaymentPlan? batchPaymentPlan = null) returns error? {

        if (batchPaymentPlan != null) {
            self.batch_payment_plan = batchPaymentPlan.cloneReadOnly();
            return;
        }

        lock {

            BatchPaymentPlan batch_payment_plan_raw;

            if (id>0) {

                batch_payment_plan_raw = check db_client->queryRow(
                `SELECT *
                FROM batch_payment_plan
                WHERE id = ${id};`);

            } else {
                return error("No id provided");
            }

            self.batch_payment_plan = batch_payment_plan_raw.cloneReadOnly();

        }

    }

    isolated resource function get id() returns int?|error {
        lock {
            return self.batch_payment_plan.id;
        }
    }

    isolated resource function get organization_id() returns int?|error {
        lock {
            return self.batch_payment_plan.organization_id;
        }
    }

    isolated resource function get batch_id() returns int?|error {
        lock {
            return self.batch_payment_plan.batch_id;
        }
    }


    isolated resource function get monthly_payment_amount() returns decimal?|error {
        lock {
            return self.batch_payment_plan.monthly_payment_amount;
        }
    }

    isolated resource function get valid_from() returns string?|error {
        lock {
            return self.batch_payment_plan.valid_from;
        }
    }

    isolated resource function get valid_to() returns string?|error {
        lock {
            return self.batch_payment_plan.valid_to;
        }
    }

    isolated resource function get created() returns string?|error {
        lock {
            return self.batch_payment_plan.created;
        }
    }
}
