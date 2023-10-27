#!/usr/bin/env bash

# set -o errexit
# set -o xtrace  # used for debugging

export AGENT_ALLOW_RUNASROOT="1" # agent is allowed to run as root

###################
#### VARIABLES ####
###################
organisationurl=${ADOORGANISATIONURL_vv} # ado organisation url
adotoken=${ADOTOKEN_vv} # ado pat that is allowed to register the agent
poolname=${POOLNAME_vv} # ado pool name for the agent
agentname=${AGENTNAME_vv} # name for the ado agent
agentusercapabilitieskey=${AGENTUSERCAPABILITIESKEY_vv} # user capabilites key for ado agent
agentusercapabilitiesvalue=${AGENTUSERCAPABILITIESVALUE_vv} # user capabilites value for ado agent

#####################################################################################################################################

######################################
#### INSTALL AND CONFIGURE DOCKER ####
######################################

sudo snap remove docker
sudo snap install docker --channel=core18/stable
sudo addgroup --system docker
sudo adduser $USER docker
newgrp docker
sudo snap disable docker
sudo snap enable docker

#####################################################################################################################################

####################################
#### INSTALL AND CONFIGURE JAVA ####
####################################

sudo apt-get -y purge openjdk-\* 
sudo add-apt-repository -y ppa:openjdk-r/ppa
sudo apt-get -y update
sudo apt install -y openjdk-11-jdk

#####################################################################################################################################

#########################################
#### INSTALL AND CONFIGURE AZURE-CLI ####
#########################################

# curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
sudo apt install --yes python3
sudo apt install --yes python3-pip

pip install azure-cli==2.51.0

#####################################################################################################################################

#######################################
#### INSTALL AND CONFIGURE KUBECTL ####
#######################################

sudo snap install kubectl --classic --channel=1.28/stable
kubectl version --client

#####################################################################################################################################

####################
#### INSTALL JQ ####
####################

sudo apt remove -y --purge jq
sudo apt install -y jq=1.6-2.1ubuntu3 # jq-1.6

#####################################################################################################################################

###########################
#### INSTALL KUSTOMIZE ####
###########################

sudo snap remove kustomize
# sudo snap install kustomize
VERSION=v5.1.1
OS=linux
ARCH=amd64
kustomize_binary_url="https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv5.1.1/kustomize_v5.1.1_linux_amd64.tar.gz"
echo $kustomize_binary_url
curl -LO $kustomize_binary_url
tar -zxvf "kustomize_v5.1.1_linux_amd64.tar.gz"
sudo mv kustomize /usr/local/bin/kustomize

#####################################################################################################################################

#############################################
#### INSTALL AND CONFIGURE THE ADO AGENT ####
#############################################

#### Download the agent package ####
echo "Downloading agent package" >> /home/azureuser/user_data_log
cd ~
wget https://vstsagentpackage.azureedge.net/agent/3.220.5/vsts-agent-linux-x64-3.220.5.tar.gz

if [ $? -eq 0 ]
then
    echo "Agent Package downloaded successfully" >> /home/azureuser/user_data_log
else
    echo "Error downloading the agent package" >> /home/azureuser/user_data_log
fi

echo "\n" >> /home/azureuser/user_data_log
echo "--------------------------------" >> /home/azureuser/user_data_log
echo "\n" >> /home/azureuser/user_data_log

#### Extract the agent package ####
echo "Extracting agent package" >> /home/azureuser/user_data_log

mkdir myagent && cd myagent

tar zxvf ~/vsts-agent-linux-x64-3.220.5.tar.gz

if [ $? -eq 0 ]
then
    echo "Agent Package extracted successfully" >> /home/azureuser/user_data_log
else
    echo "Error extracting the agent package" >> /home/azureuser/user_data_log
fi

echo "\n" >> /home/azureuser/user_data_log
echo "--------------------------------" >> /home/azureuser/user_data_log
echo "\n" >> /home/azureuser/user_data_log

#### Configuring the agent ####
echo "Configuring the agent" >> /home/azureuser/user_data_log

./config.sh --unattended --url $organisationurl --auth pat --token $adotoken --pool $poolname --agent $agentname --work _work --replace

if [ $? -eq 0 ]
then
    echo "Agent Configured" >> /home/azureuser/user_data_log
else
    echo "Error Configuring the agent" >> /home/azureuser/user_data_log
fi

echo "\n" >> /home/azureuser/user_data_log
echo "--------------------------------" >> /home/azureuser/user_data_log
echo "\n" >> /home/azureuser/user_data_log

#### removing the agent package ####
echo "removing the agent package" >> /home/azureuser/user_data_log
rm -f ~/vsts-agent-linux-x64-3.220.5.tar.gz

if [ $? -eq 0 ]
then
    echo "Agent Package Deleted" >> /home/azureuser/user_data_log
else
    echo "Error deleting the agent package" >> /home/azureuser/user_data_log
fi

echo "\n" >> /home/azureuser/user_data_log
echo "--------------------------------" >> /home/azureuser/user_data_log
echo "\n" >> /home/azureuser/user_data_log

### installing agent as systemd service ####
echo "Installing agent as systemd service" >> /home/azureuser/user_data_log
sudo ./svc.sh install $USER

if [ $? -eq 0 ]
then
    echo "Agent installed as systemd service" >> /home/azureuser/user_data_log
else
    echo "Error installing agent as systemd service" >> /home/azureuser/user_data_log
fi

echo "\n" >> /home/azureuser/user_data_log

#### starting agent as systemd service ####
echo "Starting systemd service" >> /home/azureuser/user_data_log
sudo ./svc.sh start

if [ $? -eq 0 ]
then
    echo "Agent Service Started" >> /home/azureuser/user_data_log
else
    echo "Error starting the service" >> /home/azureuser/user_data_log
fi

#####################################################################################################################################

###############################################
#### Add user capabilites to the ADO Agent ####
###############################################

user="user"

# Base64-encode the Personal Access Token (PAT) appropriately
base64AuthInfo=$(echo -n "$user:$adotoken" | base64)

#### Get the pool id using pool name ####

# API URL to get the pool id
baseUri="$organisationurl/_apis/distributedtask/pools?poolName=$poolname&api-version=5.1"

# Request to get pool id using pool name
poolidresponse=$(curl -X GET -H "Authorization: Basic $base64AuthInfo" -H "Content-Type: application/json" "$baseUri")

poolid=$(echo $poolidresponse | jq .value[0].id)
echo "=========================================================="
echo "poolID: $poolid"
echo "=========================================================="

#### Get the agent id ####

baseUri="$organisationurl/_apis/distributedtask/pools/$poolid/agents?api-version=6.1-preview.1"

# Request to get pool id using pool name
response=$(curl -X GET -H "Authorization: Basic $base64AuthInfo" -H "Content-Type: application/json" "$baseUri")

agentid=$(echo $response | jq .value | jq -r --arg AGENTNAME "$agentname" '.[] | select(.name==$AGENTNAME)' | jq .id)
echo "=========================================================="
echo "agentID: $agentid"
echo "=========================================================="

#### add user capabilites to the ado agent ####

baseUri="$organisationurl/_apis/distributedtask/pools/$poolid/agents/$agentid/usercapabilities?api-version=5.0"

# Create JSON body with the user capabilites key:value
createJsonBody() {
    cat << EOF
{"$agentusercapabilitieskey": "$agentusercapabilitiesvalue"}
EOF
}

jsonbody=$(createJsonBody)

# Update the Agent user capability
agentcapability=$(curl -X PUT -H "Authorization: Basic $base64AuthInfo" -H "Content-Type: application/json" -d "$jsonbody" "$baseUri")

echo "=========================================================="
echo "userCapabilities: $agentcapability" 
echo "=========================================================="
