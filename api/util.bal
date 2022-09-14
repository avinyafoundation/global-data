import ballerinax/mysql;
import ballerinax/mysql.driver as _;
import ballerina/sql;

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

# MySQL database client
final mysql:Client db_client = check new (host = HOST, user = USER, password = PASSWORD, port = PORT, database = DATABASE);

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
