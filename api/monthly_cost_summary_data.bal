public isolated service class MonthlyCostSummaryData {
    private MonthlyCostSummary monthly_cost_summary;

    isolated function init(int year, int organizationId) returns error? {
        // Initialize all 12 months with zero costs
        MonthlyCost[] monthlyCosts = [];
        
        foreach int month in 1 ... 12 {
            MonthlyCost monthlyCost = {
                month: month,
                estimated_cost: 0,
                actual_cost: 0
            };
            monthlyCosts.push(monthlyCost);
        }

        // Corrected Query to get monthly cost summary
        // 1. Group by month of ai.start_time
        // 2. Sum estimated_cost for all approved finances
        // 3. Sum (labour_cost + total_material_cost) for actual_cost
        stream<record {|int month; decimal total_estimated; decimal total_actual;|}, error?> costStream;

        lock {
            costStream = db_client->query(
                `SELECT 
                    MONTH(ai.start_time) as month,
                    COALESCE(SUM(mf.estimated_cost), 0) as total_estimated,
                    COALESCE(SUM(mf.labour_cost + COALESCE(mc.total_material_cost, 0)), 0) as total_actual
                FROM activity_instance ai
                INNER JOIN maintenance_task mt ON ai.task_id = mt.id
                INNER JOIN organization_location ol ON mt.location_id = ol.id
                INNER JOIN maintenance_finance mf ON ai.id = mf.activity_instance_id
                LEFT JOIN (
                    /* Subquery to calculate material cost per financial record to prevent row duplication */
                    SELECT financial_id, SUM(quantity * unit_cost) as total_material_cost
                    FROM material_cost
                    GROUP BY financial_id
                ) mc ON mf.id = mc.financial_id
                WHERE ol.organization_id = ${organizationId}
                AND YEAR(ai.start_time) = ${year}
                AND mf.status = 'Approved'
                GROUP BY MONTH(ai.start_time)
                ORDER BY month`
            );
        }

        // Update the months that have data
        check from var costRecord in costStream
            do {
                int monthIndex = costRecord.month - 1;
                monthlyCosts[monthIndex] = {
                    month: costRecord.month,
                    estimated_cost: costRecord.total_estimated,
                    actual_cost: costRecord.total_actual
                };
            };

        check costStream.close();

        MonthlyCostSummary summary = {
            year: year,
            monthly_costs: monthlyCosts
        };

        self.monthly_cost_summary = summary.cloneReadOnly();
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