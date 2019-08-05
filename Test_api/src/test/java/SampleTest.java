import io.restassured.RestAssured;
import io.restassured.response.Response;
import org.testng.Assert;
import org.testng.annotations.BeforeTest;
import org.testng.annotations.Test;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;



import static io.restassured.RestAssured.given;

public class SampleTest {
//
//    private static final String DEPLOYMENT_PROPERTIES = "deployment.properties";//
//    Path deployPropsFile = Paths.get(INPUTS_LOCATION + File.separator + DEPLOYMENT_PROPERTIES);//
//    InputStream input = new FileInputStream((String)deployPropsFile))//
//    Properties prop = new Properties();//
//    // load a properties file//    prop.load(input);
////    // get the property value and print it out
//    System.out.println(prop.getProperty("ExternalIP"));

//    try
//
    (InputStream input = new FileInputStream("deployment.properties"))
    {
        Properties props =new Properties();
        props.load(input);
        System.out.println(props.getProperty("ExternalIP"));
        System.out.println(props.getProperty("NodePort"));
//    }

//    catch(IOException ex)
//    {
//        ex.printStackTrace();
//    }


    @BeforeTest
    public void init() throws Exception {
        try {

            //"http://0.0.0.0:9090/amazons3/"
            RestAssured.baseURI = "http://ExternalIP:NodePort/amazons3/";
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
                Assert.assertTrue(response.body().asString().contains("Your previous request to create the named bucket succeeded and you already own it."));
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
