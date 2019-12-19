#!/bin/bash
#
# Copyright Skcript Technologies Pvt. Ltd All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#
# set -ev

source ${PWD}/.env
export PATH=$PATH:${PWD}/bin
export FABRIC_CFG_PATH=${PWD}

# remove previous crypto material and config transactions
rm -fr config/*
rm -fr crypto-config/*
mkdir -p crypto-config config


# generate crypto material
cryptogen generate --config=./crypto-config.yaml
if [ "$?" -ne 0 ]; then
  echo "Failed to generate crypto material..."
  exit 1
fi

# generate genesis block for orderer
configtxgen -profile OrdererGenesis -outputBlock ./config/genesis.block
if [ "$?" -ne 0 ]; then
  echo "Failed to generate orderer genesis block..."
  exit 1
fi

# generate channel configuration transaction for My Channel
configtxgen -profile ${CHANNEL_PROFILE} -outputCreateChannelTx ./config/${CHANNEL_NAME}.tx -channelID $CHANNEL_NAME
if [ "$?" -ne 0 ]; then
  echo "Failed to generate channel configuration transaction..."
  exit 1
fi

function generateOrgAnchorPeerTx() {
    if [ $# -lt 2 ]; then
        echo "Usage: generateOrgAnchorPeer org_name asOrg_name"
        exit 1
    fi
    local orgName=$1
    local asOrgName=$2

    set -x
    # generate anchor peer for My Channel transaction as xxx Org
    configtxgen -profile ${CHANNEL_PROFILE} -outputAnchorPeersUpdate ./config/$orgName${ANCHOR_TX} -channelID $CHANNEL_NAME -asOrg $asOrgName
    local res=$?
    set +x
    if [ $res -ne 0 ]; then
      echo "Failed to generate anchor peer update for $asOrgName..."
      exit 1
    fi
}

generateOrgAnchorPeerTx ORG1 Org1MSP
generateOrgAnchorPeerTx ORG2 Org3MSP
generateOrgAnchorPeerTx ORG3 Org3MSP