
import ballerina/time;
import ballerina/log;

public function main() returns error? {
        time:Utc start_date_in_utc = check time:utcFromString("2007-12-03T10:15:30.000Z");
        time:Utc end_date_in_utc = check time:utcFromString("2007-12-13T10:15:30.000Z");

        log:printInfo(start_date_in_utc.toString());

         // Parse the date strings into time:Time objects
        time:Seconds difference_in_seconds  = time:utcDiffSeconds(end_date_in_utc,start_date_in_utc);
         
        // calculate next ending date
        time:Utc next_ending_date = time:utcAddSeconds(end_date_in_utc,difference_in_seconds);

        string utcString = time:utcToString(next_ending_date);

        log:printInfo(utcString);
        // log:printInfo(<string>civil["day".toString()]);
}
