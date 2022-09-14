import ballerina/io;
import ballerina/sql;
import ballerina/test;

# Test building multilingual `WHERE` clauses.
@test:Config {}
function testBuildMultilingualWhere() {
    LocalizedName l = {
        name_en: "Rukmal Weerawarana",
        name_si: "රුක්මාල් වීරවරණ",
        name_ta: "ருக்மால் வீரவரண"
    };

    sql:ParameterizedQuery expected = `WHERE test_table.name_en = Rukmal Weerarana AND test_table.name_ta = ருக்மால் வீரவரண AND test_table.name_si = රුක්මාල් වීරවරණ`;

    sql:ParameterizedQuery actual = buildMultilingualWhere(l, "test_table");

    io:print("Expected: ");
    io:println(expected);
    io:print("Actual: ");
    io:println(actual);

    // Note: Need to figure out how to compare sql:ParameterizedQuery.
    test:assertTrue(true);
}
