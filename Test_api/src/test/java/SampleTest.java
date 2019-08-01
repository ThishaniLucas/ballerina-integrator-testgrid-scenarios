import io.restassured.RestAssured;
import io.restassured.response.Response;
import org.testng.Assert;
import org.testng.annotations.BeforeTest;
import org.testng.annotations.Test;


import static io.restassured.RestAssured.given;

public class SampleTest {

    @BeforeTest
    public void init() throws Exception {
        try {

            RestAssured.baseURI = "http://0.0.0.0:9090/amazons3/";
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Test
    public void createbucket_Test() {
        Response response=
        given().
                when().
                post("ballerina-integrator-bucket2");
                Assert.assertTrue(response.statusCode()==500);
                Assert.assertTrue(response.body().asString().contains("Your previous request to create the named bucket succeeded and you already own it.."));
//        given().
//        when().
//        post();
//        then()
//        assertThat()
//        .statusCode(500);
    }

//    @Test(dependsOnMethods = {"createbucket_Test"})
//    public void deletebucket_Test() {
//        Response response=
//        given().
//                when().
//                delete("ballerina-integrator-bucket2");
//        Assert.assertTrue(response.statusCode()==200);
//        Assert.assertTrue(response.body().asString().contains(" hi."));
//    }




}
