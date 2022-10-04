import ballerina/test;
import ballerina/graphql;

graphql:Client test_client = check new ("http://localhost:4000/graphql");

@test:Config {}
public function testGetProvince() {
    // Attempt to get geo information for Dehiwala
    json|error? a = test_client->executeWithType(string `
        query test($name:String!) {
            geo {
                city(name: $name) {
                    name {name_en}
                    district {
                        name {name_en}
                        province {
                            name {name_en}
                        }
                    }
                }
            }
        }`,
        {"name": "Dehiwala"});

    // Verify output
    test:assertEquals(a,
        {
            "data": {
                "geo": {
                    "city": {
                        "name": {"name_en": "Dehiwala"},
                        "district": {
                            "name": {"name_en": "Colombo"},
                            "province": {"name": {"name_en": "Western"}}
                        }
                    }
                }
            }
        }
    );
}
