#!/bin/bash
# Copyright (c) 2019, WSO2 Inc. (http://wso2.org) All Rights Reserved.
#
# WSO2 Inc. licenses this file to you under the Apache License,
# Version 2.0 (the "License"); you may not use this file except
# in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

readonly utils_parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

# Install the provided Ballerina version
#
# $1 - Ballerina version
install_ballerina() {
    local ballerina_version=$1
    if [[ "${ballerina_version}" = "" ]]; then
        echo "Ballerina version not provided!"
        exit 2
    fi
    echo "Installing Ballerina version: ${ballerina_version}"
    wget https://product-dist.ballerina.io/downloads/${ballerina_version}/ballerina-${ballerina_version}.zip --quiet
    local wget_output=$?
    if [ ${wget_output} -ne 0 ]; then
        echo "Ballerina download failed!"
        exit 2;
    fi
    unzip -q ballerina-${ballerina_version}.zip -d ${utils_parent_path}
    ${utils_parent_path}/ballerina-${ballerina_version}/bin/ballerina version
    readonly ballerina_home=${utils_parent_path}/ballerina-${ballerina_version}
}

# Generates a random namespace name
generate_random_namespace() {
    echo "kubernetes-namespace"-$(generate_random_name)
}

# Generates a random database name
generate_random_name() {
    local new_uuid=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 8 | head -n 1)
    echo ${new_uuid}
}

# Wait for pod readiness
wait_for_pod_readiness() {
    local timeout=300
    local interval=20
    bash ${utils_parent_path}/wait_for_pod_ready.sh ${timeout} ${interval}

    # Temporary sleep to check whether app eventually becomes ready..
    # Ideally there should have been a kubernetes readiness probe
    # which would make sure the "Ready" status would actually mean
    # the pod is ready to accept requests (app is ready) so the above
    # readiness script would suffice
    sleep 240s
}
