#!/bin/bash

source $PWD/.env

mkdir -p $VOLUMES_DIR/chaincode
cp -R ../../chaincodes/* $VOLUMES_DIR/chaincode/
