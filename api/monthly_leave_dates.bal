import ballerina/io;
import ballerina/regex;

public isolated service class MonthlyLeaveDatesData {

    private MonthlyLeaveDates monthly_leave_dates;

    isolated function init(int? id = 0, MonthlyLeaveDates? monthlyLeaveDates = null) returns error? {

        if (monthlyLeaveDates != null) {
            self.monthly_leave_dates = monthlyLeaveDates.cloneReadOnly();
            return;
        }

        lock {

            MonthlyLeaveDates monthly_leave_dates_raw;

            if (id > 0) {

                monthly_leave_dates_raw = check db_client->queryRow(
                `SELECT *
                FROM monthly_leave_dates
                WHERE id = ${id};`);

            } else {
                return error("No id provided");
            }

            self.monthly_leave_dates = monthly_leave_dates_raw.cloneReadOnly();

        }

    }

    isolated resource function get id() returns int?|error {
        lock {
            return self.monthly_leave_dates.id;
        }
    }

    isolated resource function get year() returns int?|error {
        lock {
            return self.monthly_leave_dates.year;
        }
    }

    isolated resource function get month() returns int?|error {
        lock {
            return self.monthly_leave_dates.month;
        }
    }

    isolated resource function get organization_id() returns int?|error {
        lock {
            return self.monthly_leave_dates.organization_id;
        }
    }

    isolated resource function get batch_id() returns int?|error {
        lock {
            return self.monthly_leave_dates.batch_id;
        }
    }

    isolated resource function get leave_dates_list() returns int[]?|error {
     string[] strArray;

     lock{
        string? str = self.monthly_leave_dates.leave_dates;

        // Split the string by commas using string:split
        strArray = regex:split(str ?: "",",");
     }
        // Convert the string array to an integer array

        int[] intArray = from var s in strArray
            where s.trim() != ""
            select  check int:fromString(s);

        // Output the integer array
        io:println(intArray);

        return intArray;
        
    }

    isolated resource function get daily_amount() returns decimal?|error {
        lock {
            return self.monthly_leave_dates.daily_amount;
        }
    }

    isolated resource function get created() returns string?|error {
        lock {
            return self.monthly_leave_dates.created;
        }
    }

    isolated resource function get updated() returns string?|error {
        lock {
            return self.monthly_leave_dates.updated;
        }
    }

}
