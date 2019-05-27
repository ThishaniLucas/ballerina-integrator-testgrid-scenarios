#!/bin/bash

#-------------------------------------------------------------------------------
# Copyright (c) 2019, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#--------------------------------------------------------------------------------

set -o xtrace
echo "deploy file is found"

OUTPUT_DIR=$4
INPUT_DIR=$2
source $INPUT_DIR/infrastructure.properties

#definitions

YAMLS=$yamls

yamls=($YAMLS)
no_yamls=${#yamls[@]}
dep=($deployments)
dep_num=${#dep[@]}

function create_resources() {

    if [ -z $YAMLS ]
    then 
      echo "the yaml file is not created or the yaml file is not available"
      exit 1
    fi
    #create the deployments

    if [ -z $deployments ]
    then
      echo "No deployment is given. Please makesure to give atleast one deployment"
      exit 1
    fi

    i=0;
    for ((i=0; i<$no_yamls; i++))
    do 
      kubectl create -f ${yamls[$i]}
    done

    readiness_deployments

    i=0;
    for ((i=0; i<$dep_num; i++))
    do 
      kubectl expose deployment ${dep[$i]} --name=${dep[$i]}  --type=LoadBalancer -n $namespace
    done

    readinesss_services

    echo "namespace=$namespace" >> $OUTPUT_DIR/deployment.properties

}

function readiness_deployments(){
    i=0;
    for ((i=0; i<$dep_num; i++)) ; do 
      num_true=0;
      while [ "$num_true" -eq "0" ] ; do 
        sleep 5
        deployment_status=$(kubectl get deployments -n $namespace ${dep[$i]} -o jsonpath='{.status.conditions[?(@.type=="Available")].status}')
        if [ "$deployment_status" == "True" ] ; then
          num_true=1;
        fi
      done
    done
}

function readinesss_services(){
    i=0;
    for ((i=0; i<$dep_num; i++)); do 
      external_ip=""
      while [ -z $external_ip ]; do
        echo "Waiting for end point..."
        external_ip=$(kubectl get service ${dep[$i]} --template="{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}")
        [ -z "$external_ip" ] && sleep 10
      done
      echo "APIMServiceCarbonURL=https://$external_ip:9443/carbon" >> $OUTPUT_DIR/deployment.properties
      echo "APIMServicePublisherURL=https://$external_ip:9443/publisher" >> $OUTPUT_DIR/deployment.properties
      echo "APIMServiceStoreURL=https://$external_ip:9443/store" >> $OUTPUT_DIR/deployment.properties
      echo "APIMGatewayHTTPSEndpoint=$external_ip:8243" >> $OUTPUT_DIR/deployment.properties
      echo "APIMGatewayHTTPEndpoint=$external_ip:8280" >> $OUTPUT_DIR/deployment.properties

    done
}

create_resources
