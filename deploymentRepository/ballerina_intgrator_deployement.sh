-- common.sh 
-- deployment_utils.sh
-- setup_deployment_env.sh
#! /bin/bash

# Copyright (c) 2018, WSO2 Inc. (http://wso2.com) All Rights Reserved.
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

set -e
set -o xtrace
input_dir=$2
output_dir=$4


echo "=== Install Ballerina ==="

pwd
#to do --> get thet parameters from input dir
echo "=== Read values from deployment.properties ==="
input_dir=$2
echo "My INPUTS_DIR is $input_dir"

# FUNCTION get_property
# ARG 1 - path to the properties file
# ARG 2 - key name to extract
get_property() {
    prop_file=$1
    key=$2
    cat $prop_file | grep $key | tail -n 1 | cut -d'=' -f2
}

ballerina_integrator_aws_s3_access_key=$(get_property $input_dir/infrastructure.properties ballerina_integrator_aws_s3_access_key)
ballerina_integrator_aws_s3_secret_key=$(get_property $input_dir/infrastructure.properties ballerina_integrator_aws_s3_secret_key)

echo extracted ballerina_integrator_aws_s3_access_key = $ballerina_integrator_aws_s3_access_key

sleep 1;

#setup git
setup_git(){
# Add github key to known host
ssh-keyscan -H "github.com" >> ~/.ssh/known_hosts
# Start the ssh-agent
eval "$(ssh-agent -s)"
# Write ssh key to id-rsa file and set the permission
echo "$1" > ~/.ssh/id_rsa
username=$(id -un)

if [ "$username" == "centos" ]; then
    chmod 600 /home/centos/.ssh/id_rsa
else
    chmod 600 /home/ubuntu/.ssh/id_rsa
fi

# Add ssh key to the agent
ssh-add ~/.ssh/id_rsa

}

setup_deployment(){
    download_ballerina
    download_s3
    build_bal_service
    write_properties_to_data_bucket
    local is_debug_enabled=${infra_config["isDebugEnabled"]}
    if [ "${is_debug_enabled}" = "true" ]; then
        print_kubernetes_debug_info
    fi
}

#Download the ballerina run script
download_ballerina(){
# git clone https://github.com/ballerina-platform/ballerina-scenario-tests.git
git clone https://github.com/KasunAratthanage/ballerina-scenario-tests.git
cd ballerina-scenario-tests/test-grid-scripts/common
source usage.sh
cd ../setup
source setup_deployment_env.sh 
cd ../../../
ls
echo "=== Ballerina Installed ==="
}


#Download S3 connector
download_s3(){
git clone https://github.com/KasunAratthanage/module-amazons3.git
cd module-amazons3
${ballerina_home}/bin/ballerina build amazons3 --skiptests
# ${ballerina_home}/bin/ballerina install amazons3 --no-build
# ballerina build --skiptests amazons3
# ballerina install --no-build amazons3

echo "=== Successfully setup s3  ==="

}

pwd

#Copy ballerina service to s3
build_bal_service(){
pwd
cd ..
pwd
git clone https://github.com/KasunAratthanage/ballerina-integrator
cd ballerina-integrator
git checkout test_s3connector
pwd
cd examples/s3
cp api_test.bal ../../../module-amazons3
# to do --> need to add conf.bal here
# ballerina build api_test.bal
cd ../../../
ls
pwd
cd module-amazons3
ls
touch ballerina.conf
ls
chmod -R 744 ballerina.conf
echo "ballerina_integrator_aws_s3_access_key" >> ~/ballerina.conf
echo "ballerina_integrator_aws_s3_secret_key" >> ~/ballerina.conf
${ballerina_home}/bin/ballerina build api_test.bal

echo "=== Ballerina service build successfully ==="
pwd
ls
# Run generated docker image
kubectl apply -f /module-amazons3/target/kubernetes/api_test --namespace=${cluster_namespace}
# kubectl apply -f /testgrid/testgrid-home/jobs/kasunA-ballerina-integrator-k8s/kasunA-ballerina-integrator-k8s_deployment_CentOS-7.5_MySQL-5.7_run67/workspace/DeploymentRepository/module-amazons3/target/kubernetes/api_test --namespace=${cluster_namespace}

}

write_properties_to_data_bucket() {
    local external_ip=$(kubectl get nodes -o=jsonpath='{.items[0].status.addresses[?(@.type=="ExternalIP")].address}')
    local node_port=$(kubectl get svc ballerina-guides-employee-database-service -o=jsonpath='{.spec.ports[0].nodePort}')
    declare -A deployment_props
    deployment_props["ExternalIP"]=${external_ip}
    deployment_props["NodePort"]=${node_port}
    write_to_properties_file ${output_dir}/deployment.properties deployment_props
    local is_debug_enabled=${infra_config["isDebugEnabled"]}
    if [ "${is_debug_enabled}" = "true" ]; then
        echo "ExternalIP: ${external_ip}"
        echo "NodePort: ${node_port}"
    fi
}


setup_deployment
