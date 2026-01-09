public isolated service class MonthlyReportData {

    private MonthlyReport monthly_report;

    isolated function init(int? id = 0, MonthlyReport? monthlyReport = null) returns error? {

        self.monthly_report = monthlyReport is MonthlyReport
        ? monthlyReport.cloneReadOnly()
        : {
            totalTasks: 0,
            completedTasks: 0,
            pendingTasks: 0,
            inProgressTasks: 0,
            totalCosts: 0.0,
            totalUpcomingTasks: 0,
            nextMonthlyEstimatedCost: 0.0
        };
    }

    isolated resource function get totalTasks() returns int?|error {
        lock {
            return self.monthly_report.totalTasks;
        }
    }

    isolated resource function get completedTasks() returns int?|error {
        lock {
            return self.monthly_report.completedTasks;
        }
    }

    isolated resource function get pendingTasks() returns int?|error {
        lock {
            return self.monthly_report.pendingTasks;
        }
    }

    isolated resource function get inProgressTasks() returns int?|error {
        lock {
            return self.monthly_report.inProgressTasks;
        }
    }

    isolated resource function get totalCosts() returns decimal?|error {
        lock {
            return self.monthly_report.totalCosts;
        }
    }

    isolated resource function get totalUpcomingTasks() returns int?|error {
        lock {
            return self.monthly_report.totalUpcomingTasks;
        }
    }

    isolated resource function get nextMonthlyEstimatedCost() returns decimal?|error {
        lock {
            return self.monthly_report.nextMonthlyEstimatedCost;
        }
    }
    
}