import ballerina/graphql;

service graphql:Service /graphql on new graphql:Listener(4000) {
    resource function get geo() returns GeoData {
        return new ();

    }
}
