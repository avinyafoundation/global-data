public isolated service class MonthlyCostSummaryData {
    private MonthlyCostSummary monthly_cost_summary;

    isolated function init(MonthlyCostSummary monthly_cost_summary) returns error? {
        self.monthly_cost_summary = monthly_cost_summary.cloneReadOnly();
    }

    isolated resource function get year() returns int? {
        lock {
            return self.monthly_cost_summary.year;
        }
    }

    isolated resource function get monthly_costs() returns MonthlyCostData[]|error? {
        MonthlyCost[]? costs;
        lock {
            costs = self.monthly_cost_summary.monthly_costs.clone();
        }

        if costs is () {
            return [];
        }

        MonthlyCostData[] monthlyCostDatas = [];
        foreach MonthlyCost cost in costs {
            MonthlyCostData monthlyCostData = new (cost);
            monthlyCostDatas.push(monthlyCostData);
        }

        return monthlyCostDatas;
    }
}