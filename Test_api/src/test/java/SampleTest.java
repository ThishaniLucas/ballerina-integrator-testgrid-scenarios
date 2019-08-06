
import io.restassured.RestAssured;
import io.restassured.response.Response;
import org.testng.Assert;
import org.testng.annotations.BeforeTest;
import org.testng.annotations.Test;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;



import static io.restassured.RestAssured.given;

public class SampleTest {

    try(InputStream input = new FileInputStream("deployment.properties"))
    {
        Properties props =new Properties();
        props.load(input);
        System.out.println(props.getProperty("ExternalIP"));
        System.out.println(props.getProperty("NodePort"));
    }

catch(IOException ex)
    {
        ex.printStackTrace();
    }

    public SampleTest() throws FileNotFoundException, IOException {
    }


    @BeforeTest
    public void init() throws Exception {
        try {
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
                post("ballerina-integrator-bucket19");
                Assert.assertTrue(response.statusCode()==200);

    }

    @Test (dependsOnMethods = {"createbucket_Test"})
    public void deletebucket_Test() {
        Response response=
                given().
                        when().
                        delete("http://ExternalIP:NodePort/amazons3/ballerina-integrator-bucket19");
        Assert.assertTrue(response.statusCode()==200);

    }
}

