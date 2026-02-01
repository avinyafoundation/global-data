public isolated service class MonthlyCostData {
    private MonthlyCost monthly_cost;

    isolated function init(MonthlyCost monthlyCost) {
        self.monthly_cost = monthlyCost.cloneReadOnly();
    }

    isolated resource function get month() returns int? {
        lock {
            return self.monthly_cost.month;
        }
    }

    isolated resource function get estimated_cost() returns decimal? {
        lock {
            return self.monthly_cost.estimated_cost;
        }
    }

    isolated resource function get actual_cost() returns decimal? {
        lock {
            return self.monthly_cost.actual_cost;
        }
    }
}
