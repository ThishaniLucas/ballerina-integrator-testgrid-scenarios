import io.restassured.RestAssured;
import io.restassured.response.Response;
import org.testng.Assert;
import org.testng.annotations.BeforeTest;
import org.testng.annotations.Test;
import java.io.FileInputStream;
import java.io.InputStream;
import java.nio.file.Path;
import java.sql.SQLOutput;
import java.util.Properties;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.io.File;

import static io.restassured.RestAssured.given;

public class SampleTest {

    //private static final String INPUTS_LOCATION = System.getProperty("data.bucket.location");
    private static final String INPUTS_LOCATION = System.getenv("input_dir");

    private static String externalip ;
    private static String nodeport ;

    static void test()  throws Exception {


        System.out.println();
        //InputStream input = new FileInputStream("/home/kasun/Documents/Test_grid/Test_api/src/test/java/deployment.properties");
        InputStream input = new FileInputStream(INPUTS_LOCATION+"/deployment.properties");
        Properties props =new Properties();
        props.load(input);
        externalip = props.getProperty("ExternalIP");
        nodeport = props.getProperty("NodePort");
        System.out.println(externalip);
        System.out.println(nodeport);
        System.out.println("************INPUTS_LOCATION******************"+INPUTS_LOCATION);
    }

    @BeforeTest
    public void init() throws Exception {
        try {
        test();
        RestAssured.baseURI = "http://"+ externalip +":"+ nodeport+"/amazons3/";

        } catch (Exception e) {
                e.printStackTrace();
        }
    }

    @Test
    public void createbucke_Test() {
        Response response=
        given().
                when().
                post("ballerina-integrator-bucket22");
                Assert.assertTrue(response.statusCode()==200);
    }

    @Test(dependsOnMethods = {"createbucke_Test"})
    public void deletebucket_Test() {

        Response response=
                given().
                when().
                delete("ballerina-integrator-bucket22");
                Assert.assertTrue(response.statusCode()==200);
    }
}

