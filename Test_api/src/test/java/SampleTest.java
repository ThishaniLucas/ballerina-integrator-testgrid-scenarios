import io.restassured.RestAssured;
import io.restassured.response.Response;
import org.testng.Assert;
import org.testng.annotations.BeforeTest;
import org.testng.annotations.Test;
import java.io.FileInputStream;
import java.io.InputStream;
import java.util.Properties;

import static io.restassured.RestAssured.given;

public class SampleTest {
       
    private static String externalip ;
    private static String nodeport ;

    static void test()  throws Exception {

        private static final String INPUTS_LOCATION = System.getProperty("data.bucket.location");
        System.out.println();
        InputStream input = new FileInputStream("INPUTS_LOCATION/deployment.properties");
        Properties props =new Properties();
        props.load(input);
        externalip = props.getProperty("ExternalIP");
        nodeport = props.getProperty("NodePort");
        System.out.println(externalip);
        System.out.println(nodeport);
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

