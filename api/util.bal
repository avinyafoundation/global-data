import ballerinax/mysql;
import ballerinax/mysql.driver as _;
import ballerina/sql;
import ballerina/io;
import ballerina/jwt;
import ballerina/http;
import ballerina/time;
import ballerina/log;
import ballerina/regex;

# Database user
configurable string USER = ?;
# Database password
configurable string PASSWORD = ?;
# Database host
configurable string HOST = ?;
# Database port
configurable int PORT = ?;
# Database name
configurable string DATABASE = ?;

#Fcm scope
configurable string FCM_SCOPE = ?;

#Fcm cli email
configurable string FCM_CLIENT_EMAIL = ?;

#Fcm Token url
configurable string FCM_TOKEN_URL = ?;

#Fcm Project id
configurable string FCM_PROJECT_ID = ?;


# MySQL database client
final mysql:Client db_client = check new (host = HOST, user = USER, password = PASSWORD, port = PORT, database = DATABASE);

// mysql:Client db_client = check new (host = HOST, port = PORT, user = USER, password = PASSWORD, database = DATABASE, options = {
//         ssl: {
//             mode: mysql:SSL_PREFERRED
//         },
//         serverTimezone: "Asia/Calcutta"
//     });

# Function to build the `WHERE` clause for a SQL query, given a
# `LocalizedName` record. Iterates through the record and dynamically
# constructs the `WHERE` clause.
#
# + name - `LocalizedName` to be used for construction.  
# + table_name - Name of the table being queried.
# + return - Return Value Description
isolated function buildMultilingualWhere(LocalizedName name, string table_name) returns sql:ParameterizedQuery {
    sql:ParameterizedQuery where_clause = `WHERE `;
    foreach int i in 0 ..< name.keys().length() {
        sql:ParameterizedQuery where_component = sql:queryConcat(`${table_name}.${name.keys()[i]} = ${<sql:Value>name[name.keys()[i]]}`);
        where_clause = sql:queryConcat(where_clause, where_component);
        if (i < name.keys().length() - 1) {
            where_clause = sql:queryConcat(where_clause, ` AND `);
        }
    }
    return where_clause;
}

isolated function getAccessToken() returns string|error {
    // Get the temporary PEM file
    string keyFilePath = "./private_key.pem";

    // Time values for JWT claims
    time:Utc now = time:utcNow(());
    int iat = now[0]; 
  
    int exp =iat +3600;   // expires 1 hour later

    map<json> claims = {
    "iss": FCM_CLIENT_EMAIL,
    "scope":FCM_SCOPE,
    "aud": FCM_TOKEN_URL,
    iat: iat,
    exp: exp
    };

    jwt:IssuerConfig issuerConfig = {
    issuer: FCM_CLIENT_EMAIL,
    audience:FCM_TOKEN_URL,
    expTime: 3600,
    signatureConfig: {
        config: {
            keyFile: keyFilePath
        }
    },
    customClaims:claims
   };

     // The jwt:issue method handles the signing with RS256 algorithm
    string signedJwt = check jwt:issue(issuerConfig);
    io:println("✅ JWT created successfully.");

    // Step 4: Exchange the JWT for an access token
    json payload = {
        grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
        assertion: signedJwt
    };

    http:Client tokenClient = check new (FCM_TOKEN_URL);
    http:Response resp = check tokenClient->post("", payload, {
        "Content-Type": "application/json"
    });

    json respJson = check resp.getJsonPayload();

    map<json> respMap = check respJson.cloneWithType();

    return respMap["access_token"].toString();
}

//send notification to a single user by userId
isolated function sendNotificationToUser(int personId,NotificationRequest request) returns error?{

    string|error accessToken = getAccessToken();

    if accessToken is string {


        PersonFcmToken|error personFcmTokenRaw = db_client->queryRow(
                                            `SELECT *
                                            FROM person_fcm_token
                                            WHERE person_id = ${personId};`
                                        );

        if (personFcmTokenRaw is error) {
            return error(string `Failed to fetch FCM token for personId:${personId.toString()}`);
        }

        if personFcmTokenRaw.id == (){
            return error(string `No FCM Token found for personId:${personId.toString()}`);
        }

        string fcmToken = personFcmTokenRaw.fcm_token ?:"";

        error? result = sendNotificationToToken(fcmToken,accessToken,
                                                request.title.toString(),
                                                request.body.toString());
        if result is error {
          log:printError(string `Error sending notification :${result.message()}`);
        }

    }else{
        return error(string `Failed to retrieve access token. Error:, ${accessToken.message()}`);
    }
}

//Function to Fetch All FCM Tokens
isolated function fetchAllFcmTokens() returns string[]|error? {

        stream<record { string fcm_token; }, error?> resultStream;

        lock{
            resultStream  = db_client->query(
                `SELECT fcm_token FROM person_fcm_token WHERE fcm_token IS NOT NULL;`
            );
        }

        string[] tokens = [];

        check from record { string fcm_token; } row in resultStream
           do{
              tokens.push(row.fcm_token);
           };

        return tokens;
}

//Send Notification to One FCM Token
isolated function sendNotificationToToken(string fcmToken,string accessToken,string title,string body) returns  error?{

      json payLoad = {
            "message":{
            "token":fcmToken,
            "notification":{
                    "title":title,
                    "body": body
                }
            }
        };

        http:Client fcmClient = check new(FCM_URL);
        http:Response response = check fcmClient->post("",payLoad,{
                    "Authorization": "Bearer " + accessToken,
                    "Content-Type": "application/json"
        });
        
        if(response.statusCode == http:STATUS_CREATED){
            //print the response payload
            json? responsePayload = check response.getJsonPayload();
            io:println("Notification send successfully: ",responsePayload); 
        }else{
            //Handle other status codes
            string? errorPayload = check response.getTextPayload();
            if(errorPayload is string){
            io:println("Error details :",errorPayload);
            }
        }

}

//Send Notification to All Users
isolated  function sendNotificationToAllUsers(NotificationRequest request) returns error?{

    string|error accessToken = getAccessToken();

    if accessToken is string {

            string[]|error? fcmTokens  = fetchAllFcmTokens();

            if(fcmTokens is string[]){
               foreach var token in fcmTokens {
                  error?  result = sendNotificationToToken(token,accessToken,
                                                      request.title.toString(),
                                                      request.body.toString());
                   if result is error {
                         log:printError(string `Error sending notification :${result.message()}`);
                    }
               }
            }else{
              return error(string `Error while fetching tokens`);
            }

    }else{
        return error(string `Failed to retrieve access token. Error:, ${accessToken.message()}`);
    }

}

//execution time for this below method:63.38 ms.Execution under 100 ms is excellent
public function addDaysToDate(string date,int dayCount) returns string|error{
                           
    time:Utc startDateInUtc = check time:utcFromString(toIso8601Utc(date));
   
    // calculate ending date
    time:Utc endDate = time:utcAddSeconds(startDateInUtc,dayCount*86400); //86400=number of seconds in a single day
    
    string endDateInString = time:utcToString(endDate);
    
    //convert dateTime into human-readable format
    string removeIt = removeTandZ(endDateInString);
    return removeIt;
}

function toIso8601Utc(string dateTime) returns string {
    // Replace space with 'T' and append 'Z'
   // Replace space between date and time with 'T'
    string iso = regex:replaceAll(dateTime, "\\s+", "T");
    // Append 'Z' to mark UTC
    return iso + "Z";
}

function removeTandZ(string isoDateTime) returns string {
    // Replace 'T' with space
    string withoutT = regex:replaceAll(isoDateTime, "T", " ");

    // Remove trailing 'Z'
    return regex:replaceAll(withoutT, "Z$", "");
}

function contains(int[] arr, int value) returns boolean {
    foreach int i in arr {
        if i == value {
            return true;
        }
    }
    return false;
}

function getRecurrenceDays(string scheduleType) returns int {
    // Normalize input (trim spaces, make uppercase)
    string frequency = scheduleType.trim().toUpperAscii();

    if frequency == "DAILY" {
        return 1;
    } else if frequency == "WEEKLY" {
        return 7;
    } else if frequency == "BIWEEKLY" {
        return 14;
    } else if frequency == "MONTHLY" {
        return 30;
    } else if frequency == "QUARTERLY" {
        return 120;
    } else if frequency == "BIANNUALLY"{
        return 180;
    } else if frequency == "ANNUALLY"{
        return 365;
    }else {
        return 0; // default/fallback
    }
}