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
//------------------------------------------------------
//    (InputStream input = new FileInputStream("deployment.properties"))
////    {
//        Properties props =new Properties();
//        props.load(input);
//        System.out.println(props.getProperty("ExternalIP"));
//        System.out.println(props.getProperty("NodePort"));

        // --------------------------------------------------
//    }

//    catch(IOException ex)
//    {
//        ex.printStackTrace();
//    }

    @BeforeTest
    public void init() throws Exception {
        try {
            //"http://0.0.0.0:9090/amazons3/"
            //ExternalIP:NodePort
            RestAssured.baseURI = "http://0.0.0.0:9090/amazons3/";
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    //Create bucket in the amazone s3
    @Test
    public void createbucket_Test() {
        Response response=
        given().
                when().
                    post("ballerina-integrator-bucket7");
                Assert.assertTrue(response.statusCode()==200);
                Assert.assertTrue(response.body().asString().contains("ballerina-integrator-bucket6 created from Amazon S3"));
//        given().
//        when().
//        post();
//        then()
//        assertThat()
//        .statusCode(500);
    }



//    @Test
//    public void createObject_Test(){
//        //curl -v -X POST --data @content.json http://localhost:9090/amazons3/firstbalbucket/firstObject.json --header "Content-Type:application/json"
//        Response response=
//
//    }
//
//
//    @Test
//    public void getObject_Test(){
//    //curl -v -X DELETE http://localhost:9090/amazons3/firstbalbucket/firstObject.json
//
//
//    }
//
//
//    @Test
//    public void deleteObject_Test(){
//        //curl -v -X DELETE http://localhost:9090/amazons3/firstbalbucket
//
//
//    }

    //Delete bucket in the amazone s3

    @Test (dependsOnMethods = {"createbucket_Test"})
    public void deletebucket_Test() {
        Response response=
                given().
                        when().
                        post("ballerina-integrator-bucket6");
        Assert.assertTrue(response.statusCode()==200);
        Assert.assertTrue(response.body().asString().contains("ballerina-integrator-bucket6 deleted from Amazon S3."));
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
