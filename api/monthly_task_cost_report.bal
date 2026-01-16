public isolated service class MaintenanceMonthlyTaskCostReportData {

    private MaintenanceMonthlyTaskCostReport report;

    isolated function init(
        MaintenanceMonthlyTaskCostReport? report = null
    ) returns error? {

        self.report = report is MaintenanceMonthlyTaskCostReport
            ? report.cloneReadOnly()
            : {
                organizationId: 0,
                year: 0,
                month: 0,
                totalActualCost: 0.0,
                totalEstimatedCost: 0.0,
                tasks: []
            };
    }

    isolated resource function get organizationId() returns int|error {
        lock {
            return self.report.organizationId;
        }
    }

    isolated resource function get year() returns int|error {
        lock {
            return self.report.year;
        }
    }

    isolated resource function get month() returns int|error {
        lock {
            return self.report.month;
        }
    }

    isolated resource function get totalActualCost() returns decimal|error {
        lock {
            return self.report.totalActualCost;
        }
    }

    isolated resource function get totalEstimatedCost() returns decimal|error {
        lock {
            return self.report.totalEstimatedCost;
        }
    }

    isolated resource function get tasks()
        returns MaintenanceTaskCostSummaryData[]|error {

        MaintenanceTaskCostSummary[] snapshot;

        lock {
            snapshot = self.report.tasks.cloneReadOnly();
        }

        MaintenanceTaskCostSummaryData[] result = [];

        foreach var t in snapshot {
            MaintenanceTaskCostSummaryData|error summary = new (t);
            if summary is error {
                return summary;
            }
            result.push(summary);
        }

        return result;
    }


}




public isolated service class MaintenanceTaskCostSummaryData {

    private MaintenanceTaskCostSummary taskSummary;

    isolated function init(
        MaintenanceTaskCostSummary? taskSummary = null
    ) returns error? {

        self.taskSummary = taskSummary is MaintenanceTaskCostSummary
            ? taskSummary.cloneReadOnly()
            : {
                taskId: 0,
                taskTitle: "",
                actualCost: 0.0,
                estimatedCost: 0.0
            };
    }

    isolated resource function get taskId() returns int|error {
        lock {
            return self.taskSummary.taskId;
        }
    }

    isolated resource function get taskTitle() returns string|error {
        lock {
            return self.taskSummary.taskTitle;
        }
    }

    isolated resource function get actualCost() returns decimal|error {
        lock {
            return self.taskSummary.actualCost;
        }
    }

    isolated resource function get estimatedCost() returns decimal|error {
        lock {
            return self.taskSummary.estimatedCost;
        }
    }
}


