//
// Copyright (c) 2018, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//

import ballerina/config;
import ballerina/http;
import ballerina/log;
import wso2/amazons3;
import ballerinax/kubernetes;



// Constants for error code and messages.
const string ERROR_CODE = "Sample Error";
const string RESPOND_ERROR_MSG = "Error in responding to client.";
const string CLIENT_CREATION_ERROR_MSG = "Error while creating the AmazonS3 client.";
const string BUCKET_CREATION_ERROR_MSG = "Error while creating bucket on Amazon S3.";
const string PAYLOAD_EXTRACTION_ERROR_MSG = "Error while extracting the payload from request.";
const string OBJECT_CREATION_ERROR_MSG = "Error while creating object on Amazon S3.";
const string OBJECT_DELETION_ERROR_MSG = "Error while deleting object from Amazon S3.";
const string BUCKET_DELETION_ERROR_MSG = "Error while deleting bucket from Amazon S3.";
const string INVALID_PAYLOAD_MSG = "Invalid request payload";

// Read accessKey and secretKey from config files.
string accessKeyId = config:getAsString("ACCESS_KEY_ID");
string secretAccessKey = config:getAsString("SECRET_ACCESS_KEY");

// Create Amazons3 client configration with the above accesskey and secretKey values.
amazons3:ClientConfiguration amazonS3Config = {
    // accessKeyId: accessKeyId,
    // secretAccessKey: secretAccessKey
    accessKeyId: "***",
    secretAccessKey: "***"
    // region: "us-east-1"
};

//Add `@kubernetes:Service` to a listner endpoint to expose the endpoint as Kubernetes Service.
@kubernetes:Service {
    //Service type is `NodePort`.
    serviceType: "NodePort"
}
//Add `@kubernetes:Ingress` to a listner endpoint to expose the endpoint as Kubernetes Ingress.
@kubernetes:Ingress {
    //Hostname of the service is `abc.com`.
    hostname: "abc.com"
}
listener http:Listener awsS3EP = new http:Listener(9090);

//Add `@kubernetes:ConfigMap` annotation to a Ballerina service to mount configs to the container.
@kubernetes:ConfigMap {
    //Path to the ballerina.conf file.
    //If a releative path is provided, the path should be releative to where the `ballerina build` command is executed.
    conf: "./ballerina.conf"
}
//Add `@kubernetes:Deployment` annotation to a Ballerna service to generate Kuberenetes Deployment for a Ballerina module.
@kubernetes:Deployment {
    //Enable Kubernetes liveness probe to this service.
    //livenessProbe: true,
    //Genrate Docker image with name `kubernetes:v1.0`.
    //image: "kubernetes:v.1.0"
    //Uncomment and change the following values accordingly if you are using minikube.
    image:"ballerinaintegrator/api_test:v.1.0",
    name:"api_test",
    username:"ballerinaintegrator",
    password:"ballerinaintegrator",
    push:true,
    imagePullPolicy:"Always"

}
@http:ServiceConfig {
    basePath: "/amazons3"
}
service amazonS3Service on new http:Listener(9090) {
    @http:ResourceConfig {
        methods: ["POST"],
        path: "/{bucketName}"
    }
    // Function to create a new bucket.
    resource function createBucket(http:Caller caller, http:Request request, string bucketName) {
        // Create AmazonS3 client with the above amazonS3Config.
        amazons3:AmazonS3Client|error amazonS3Client = new(amazonS3Config);
        // Define new response. 
        http:Response backendResponse = new();

        if (amazonS3Client is amazons3:AmazonS3Client) {
            var response = amazonS3Client->createBucket(untaint bucketName);
            if (response is error) {
                createAndSendErrorResponse(caller, untaint <string>response.detail().message, 
                                BUCKET_CREATION_ERROR_MSG);
            } else {
                // If there is no error, then bucket created successfully. Send the success response.
                backendResponse.setTextPayload(untaint string `${bucketName} created on Amazon S3.`, 
                                contentType = "text/plain");
                respondAndHandleError(caller, backendResponse, RESPOND_ERROR_MSG);
            }
        } else {
            createAndSendErrorResponse(caller, <string>amazonS3Client.detail().message, CLIENT_CREATION_ERROR_MSG);
        }
    }

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/{bucketName}/{objectName}"
    }
    // Function to create a new object into an existing bucket.
    resource function createObject(http:Caller caller, http:Request request, string bucketName, string objectName) {
        // Create AmazonS3 client with the above amazonS3Config.
        amazons3:AmazonS3Client|error amazonS3Client = new(amazonS3Config);
        // Define new response. 
        http:Response backendResponse = new();
        string|xml|json|byte[]|error objectContent = extractRequestContent(request);
        if objectContent is error {
            createAndSendErrorResponse(caller, untaint <string>objectContent.detail().message, 
                            PAYLOAD_EXTRACTION_ERROR_MSG);
        } else {
            if (amazonS3Client is amazons3:AmazonS3Client) {
            var response = amazonS3Client->createObject(untaint bucketName, untaint objectName,
                                                untaint objectContent);
            if (response is error) {
                createAndSendErrorResponse(caller, untaint <string>response.detail().message,
                                 OBJECT_CREATION_ERROR_MSG);
            } else {
                // If there is no error, then object created successfully. Send the success response.
                backendResponse.setTextPayload(untaint string `${objectName} created on Amazon S3 bucket : ${bucketName}.`, 
                                            contentType = "text/plain");
                respondAndHandleError(caller, backendResponse, RESPOND_ERROR_MSG);
            }
        } else {
            createAndSendErrorResponse(caller, <string>amazonS3Client.detail().message, CLIENT_CREATION_ERROR_MSG);
        }
        }
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/{bucketName}/{objectName}"
    }
    // Function to get object.
    resource function getObject(http:Caller caller, http:Request request, string bucketName, string objectName) {
        // Create AmazonS3 client with the above amazonS3Config.
        amazons3:AmazonS3Client|error amazonS3Client = new(amazonS3Config);
        // Define new response. 
        http:Response backendResponse = new();
        if (amazonS3Client is amazons3:AmazonS3Client) {
            var response = amazonS3Client->getObject(untaint bucketName, untaint objectName);
            if (response is amazons3:S3Object) {
                // If there is no error, then bucket created successfully. Send the success response.
                setResponsePayload(backendResponse, untaint response);
                respondAndHandleError(caller, backendResponse, RESPOND_ERROR_MSG);
            } else {
                createAndSendErrorResponse(caller, untaint <string>response.detail().message,
                                 "Error while creating object on Amazon S3.");
            }
        } else {
            createAndSendErrorResponse(caller, <string>amazonS3Client.detail().message, CLIENT_CREATION_ERROR_MSG);
        }
    }

    @http:ResourceConfig {
        methods: ["DELETE"],
        path: "/{bucketName}/{objectName}"
    }
    // Function to delete object.
    resource function deleteObject(http:Caller caller, http:Request request, string bucketName, string objectName) {
        // Create AmazonS3 client with the above amazonS3Config.
        amazons3:AmazonS3Client|error amazonS3Client = new(amazonS3Config);
        // Define new response. 
        http:Response backendResponse = new();
        if (amazonS3Client is amazons3:AmazonS3Client) {
            var response = amazonS3Client->deleteObject(untaint bucketName, untaint objectName);
            if (response is error) {
                createAndSendErrorResponse(caller, untaint <string>response.detail().message, 
                                        OBJECT_DELETION_ERROR_MSG);
            } else {
                // If there is no error, then object deleted successfully. Send the success response.
                backendResponse.setTextPayload(untaint string `${objectName} deleted from Amazon S3 bucket : ${bucketName}.`, 
                                        contentType = "text/plain");
                respondAndHandleError(caller, backendResponse, RESPOND_ERROR_MSG);
            }
        } else {
            createAndSendErrorResponse(caller, <string>amazonS3Client.detail().message, CLIENT_CREATION_ERROR_MSG);
        }
    }

    @http:ResourceConfig {
        methods: ["DELETE"],
        path: "/{bucketName}"
    }
    // Function to delete bucket.
    resource function deleteBucket(http:Caller caller, http:Request request, string bucketName, string objectName) {
        // Create AmazonS3 client with the above amazonS3Config.
        amazons3:AmazonS3Client|error amazonS3Client = new(amazonS3Config);
        // Define new response. 
        http:Response backendResponse = new();
        if (amazonS3Client is amazons3:AmazonS3Client) {
            var response = amazonS3Client->deleteBucket(untaint bucketName);
            if (response is error) {
                createAndSendErrorResponse(caller, untaint <string>response.detail().message, 
                                        BUCKET_DELETION_ERROR_MSG);
            } else {
                // If there is no error, then bucket deleted successfully. Send the success response.
                backendResponse.setTextPayload(untaint string `${bucketName} deleted from Amazon S3.`, 
                                        contentType = "text/plain");
                respondAndHandleError(caller, backendResponse, RESPOND_ERROR_MSG);
            }
        } else {
            createAndSendErrorResponse(caller, <string>amazonS3Client.detail().message, CLIENT_CREATION_ERROR_MSG);
        }
    }
}

// Function to extract the object content from request payload
function extractRequestContent(http:Request request) returns string|xml|json|byte[]|error {
    string contentTypeStr = request.getContentType();
    if (contentTypeStr.equalsIgnoreCase("application/json")) {
        var jsonObjectContent = request.getJsonPayload();
        if (jsonObjectContent is json) {
            return jsonObjectContent;
        }
    }
    if (contentTypeStr.equalsIgnoreCase("application/xml")) {
        var xmlObjectContent = request.getXmlPayload();
        if (xmlObjectContent is xml) {
            return xmlObjectContent;
        }
    }
    if (contentTypeStr.equalsIgnoreCase("text/plain")) {
        var textObjectContent = request.getTextPayload();
        if (textObjectContent is string) {
            return textObjectContent;
        }
    }
    if (contentTypeStr.equalsIgnoreCase("application/octet-stream")) {
        var binaryObjectContent = request.getBinaryPayload();
        if (binaryObjectContent is byte[]) {
            return binaryObjectContent;
        }
    }
    error err = error(ERROR_CODE, { message : INVALID_PAYLOAD_MSG });
    return err;
}

// Function to set the object content from reponse payload
function setResponsePayload(http:Response response, amazons3:S3Object s3Object) {
    string|xml|json|byte[] objectContent = s3Object.content;
    if (objectContent is string) {
        response.setTextPayload(objectContent, contentType = "text/plain");
    } else if (objectContent is xml){
        response.setXmlPayload(objectContent, contentType = "application/xml");
    } else if (objectContent is json) {
        response.setJsonPayload(objectContent, contentType = "application/json");
    } else {
        response.setBinaryPayload(objectContent, contentType = "application/octet-stream");
    }
}

// Function to create the error response.
function createAndSendErrorResponse(http:Caller caller, string errorMessage, string respondErrorMsg) {
    http:Response response = new;
    //Set 500 status code.
    response.statusCode = 500;
    //Set the error message to the error response payload.
    response.setPayload(<string> errorMessage);
    respondAndHandleError(caller, response, respondErrorMsg);
}

// Function to send the response back to the client and handle the error.
function respondAndHandleError(http:Caller caller, http:Response response, string respondErrorMsg) {
    // Send response to the caller.
    var respond = caller->respond(response);
    if (respond is error) {
        log:printError(respondErrorMsg, err = respond);
    }
}
