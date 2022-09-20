import ballerina/http;
import ballerina/graphql;

public isolated client class Geo_dataClient {
    final graphql:Client graphqlClient;
    public isolated function init(string serviceUrl, http:ClientConfiguration clientConfig = {}) returns graphql:ClientError? {
        graphql:Client clientEp = check new (serviceUrl, clientConfig);
        self.graphqlClient = clientEp;
        return;
    }
    remote isolated function DistrictAndCityByProvince(string name) returns DistrictAndCityByProvinceResponse|graphql:ClientError {
        string query = string `query DistrictAndCityByProvince($name:String!) {geo {province(name:$name) {name {name_en} districts {name {name_en} cities {name {name_en}}}}}}`;
        map<anydata> variables = {"name": name};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <DistrictAndCityByProvinceResponse> check performDataBinding(graphqlResponse, DistrictAndCityByProvinceResponse);
    }
}
