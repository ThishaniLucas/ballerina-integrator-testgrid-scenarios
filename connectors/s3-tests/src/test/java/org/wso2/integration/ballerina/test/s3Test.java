package org.wso2.integration.ballerina.test;

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

public class s3Test {

    //private static final String INPUTS_LOCATION = System.getProperty("data.bucket.location");
    private static final String INPUTS_LOCATION = System.getenv("input_dir");

    private static String externalip ;
    private static String nodeport ;
    private static String namespace;

    static void initParams()  throws Exception {
        InputStream input = new FileInputStream(INPUTS_LOCATION+"/deployment.properties");
        Properties props =new Properties();
        props.load(input);
        externalip = props.getProperty("ExternalIP");
        nodeport = props.getProperty("NodePort");
        namespace = props.getProperty("namespace");
    }

    @BeforeTest
    public void init() throws Exception {
        try {
        initParams();
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
                post("http://"+ externalip +":"+ nodeport+"/amazons3/ballerina-integrator-bucket25");
                Assert.assertTrue(response.statusCode()==200);
    }

    @Test(dependsOnMethods = {"createbucke_Test"})
    public void deletebucket_Test() {

        Response response=
                given().
                when().
                delete("http://"+ externalip +":"+ nodeport+"/amazons3/ballerina-integrator-bucket25");
                Assert.assertTrue(response.statusCode()==200);
    }
}

