#!/bin/bash

set -ev

ENV_LOCATION=$PWD/.env
echo $ENV_LOCATION
source $ENV_LOCATION

FLAG="-i"
ARCH=$(uname)
if [ "$ARCH" == "Linux" ]; then
  FLAG="-i"
elif [ "$ARCH" == "Darwin" ]; then
  FLAG="-it"
fi

# Replace all network names
function replaceNetworkName() {
    if [ $# -lt 3 ]; then
        echo "Usage: replaceNetworkName file_path oldname newname"
        exit 1
    fi

    # TODO: have to be more specific to roll back
    sed "$FLAG" "s/$2/$3/g" $1
}
sed "$FLAG" "s/skcript/$NETWORK_NAME/g" $ZK_COMPOSE_PATH
sed "$FLAG" "s/skcript/$NETWORK_NAME/g" $KAFKA_COMPOSE_PATH # network


# Zookeeper + Kafka
sed "$FLAG" "s/- node.hostname == .*/- node.hostname == $ORG1_HOSTNAME/g" $ZK_COMPOSE_PATH
sed "$FLAG" "s/- node.hostname == .*/- node.hostname == $ORG1_HOSTNAME/g" $KAFKA_COMPOSE_PATH
# # network of ZK and Kafka
replaceNetworkName $ZK_COMPOSE_PATH $OLD_NETWORK_NAME $NETWORK_NAME
replaceNetworkName $KAFKA_COMPOSE_PATH $OLD_NETWORK_NAME $NETWORK_NAME

function replaceOrdererCompose() {
    if [ $# -lt 2 ]; then
        echo "Usage: replaceOrgFunc hostname orderer_compose_path"
        exit 1
    fi

    local HOSTNAME=$1
    local ORDERER_COMPOSE_PATH=$2

    sed "$FLAG" "s/- node.hostname == .*/- node.hostname == $HOSTNAME/g" $ORDERER_COMPOSE_PATH
    sed "$FLAG" "s#- .*/certs#- $VOLUMES_DIR/certs#g" $ORDERER_COMPOSE_PATH
}

function replacePeerCompose() {
    if [ $# -lt 2 ]; then
        echo "Usage: replaceOrgFunc hostname peer_org_compose_path"
        exit 1
    fi

    local HOSTNAME=$1
    local PEER_ORG_COMPOSE_PATH=$2

    sed "$FLAG" "s/- node.hostname == .*/- node.hostname == $HOSTNAME/g" $PEER_ORG_COMPOSE_PATH
    sed "$FLAG" "s#- .*/certs#- $VOLUMES_DIR/certs#g" $PEER_ORG_COMPOSE_PATH
}

function replaceServiceCompose() {
    if [ $# -lt 3 ]; then
        echo "Usage: replaceOrgFunc hostname service_org_compose_path org_ca_path"
        exit 1
    fi

    local HOSTNAME=$1
    local SERVICE_ORG_COMPOSE_PATH=$2

    ORG_CA_PATH=$(ls $3 | grep "_sk")
    sed "$FLAG" "s/- node.hostname == .*/- node.hostname == $HOSTNAME/g" $SERVICE_ORG_COMPOSE_PATH
    sed "$FLAG" "s#- FABRIC_CA_SERVER_CA_KEYFILE=/etc/hyperledger/fabric-ca-server-config/.*#- FABRIC_CA_SERVER_CA_KEYFILE=/etc/hyperledger/fabric-ca-server-config/$ORG_CA_PATH#g" $SERVICE_ORG_COMPOSE_PATH

    sed "$FLAG" "s#- .*/certs#- $VOLUMES_DIR/certs#g" $SERVICE_ORG_COMPOSE_PATH
    sed "$FLAG" "s#- .*/chaincode:#- $VOLUMES_DIR/chaincode:#g" $SERVICE_ORG_COMPOSE_PATH
    sed "$FLAG" "s#- .*/fabric-src/#- $VOLUMES_DIR/fabric-src/#g" $SERVICE_ORG_COMPOSE_PATH
    sed "$FLAG" "s#- .*/bin/:#- $VOLUMES_DIR/bin/:#g" $SERVICE_ORG_COMPOSE_PATH
}

replaceOrgFunc() {
    if [ $# -lt 3 ]; then
        echo "Usage: replaceOrgFunc index hostname service_org_compose_path [peer_org_compose_path]  [orderer_compose_path]"
        exit 1
    fi

    local ORG_CA_PATH="$VOLUMES_DIR/certs/crypto-config/peerOrganizations/org$1.example.com/ca/"
    local HOSTNAME=$2
    local SERVICE_ORG_COMPOSE_PATH=$3
    local PEER_ORG_COMPOSE_PATH=$4
    local ORDERER_COMPOSE_PATH=$5

    if [ -n "$ORDERER_COMPOSE_PATH" ]; then
        replaceOrdererCompose $HOSTNAME $ORDERER_COMPOSE_PATH
    fi
    if [ -n "$PEER_ORG_COMPOSE_PATH" ]; then
        replacePeerCompose $HOSTNAME $PEER_ORG_COMPOSE_PATH
    fi
    if [ -n "$SERVICE_ORG_COMPOSE_PATH" ]; then
        replaceServiceCompose $HOSTNAME $SERVICE_ORG_COMPOSE_PATH $ORG_CA_PATH
    fi
}

# Org1
replaceOrgFunc 1 ${ORG1_HOSTNAME} ${SERVICE_ORG1_COMPOSE_PATH} \
${PEER_ORG1_COMPOSE_PATH} ${ORDERER0_COMPOSE_PATH}
replaceNetworkName $SERVICE_ORG1_COMPOSE_PATH $OLD_NETWORK_NAME $NETWORK_NAME
replaceNetworkName $PEER_ORG1_COMPOSE_PATH $OLD_NETWORK_NAME $NETWORK_NAME
replaceNetworkName $ORDERER0_COMPOSE_PATH $OLD_NETWORK_NAME $NETWORK_NAME
# Org2
replaceOrgFunc 2 ${ORG2_HOSTNAME} ${SERVICE_ORG2_COMPOSE_PATH} \
${PEER_ORG2_COMPOSE_PATH} ${ORDERER1_COMPOSE_PATH}
replaceNetworkName $SERVICE_ORG2_COMPOSE_PATH $OLD_NETWORK_NAME $NETWORK_NAME
replaceNetworkName $PEER_ORG2_COMPOSE_PATH $OLD_NETWORK_NAME $NETWORK_NAME
replaceNetworkName $ORDERER1_COMPOSE_PATH $OLD_NETWORK_NAME $NETWORK_NAME
# Org3
replaceOrgFunc 3 ${ORG3_HOSTNAME} ${SERVICE_ORG3_COMPOSE_PATH} \
${PEER_ORG3_COMPOSE_PATH} ${ORDERER2_COMPOSE_PATH}
replaceNetworkName $SERVICE_ORG3_COMPOSE_PATH $OLD_NETWORK_NAME $NETWORK_NAME
replaceNetworkName $PEER_ORG3_COMPOSE_PATH $OLD_NETWORK_NAME $NETWORK_NAME
replaceNetworkName $ORDERER2_COMPOSE_PATH $OLD_NETWORK_NAME $NETWORK_NAME

if [ "$ARCH" == "Darwin" ]; then
  rm */**.ymlt
fi