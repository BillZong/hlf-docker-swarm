#!/bin/bash -eu
# Copyright London Stock Exchange Group All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#
# This script pulls docker images from the Dockerhub hyperledger repositories

source ${PWD}/.env

for imageName in ${FABRIC_IMAGE_NAMES[@]}; do
  echo "Pulling ${FABRIC_DOCKER_NS}/$imageName:${FABRIC_IMAGE_VERSION}"
  docker pull ${FABRIC_DOCKER_NS}/$imageName:${FABRIC_IMAGE_VERSION}
  docker tag ${FABRIC_DOCKER_NS}/$imageName:${FABRIC_IMAGE_VERSION} ${FABRIC_DOCKER_NS}/$imageName:latest
done

for imageName in ${FABRIC_THIRD_PARTY_IMAGE_NAMES[@]}; do
  echo "Pulling "
  docker pull ${FABRIC_DOCKER_NS}/$imageName:${THIRD_PARTY_IMAGE_VERSION}
  docker tag ${FABRIC_DOCKER_NS}/$imageName:${THIRD_PARTY_IMAGE_VERSION} ${FABRIC_DOCKER_NS}/$imageName:latest
done

# echo "Pulling ${FABRIC_DOCKER_NS}/fabric-baseos:${THIRD_PARTY_IMAGE_VERSION}"
# docker pull ${FABRIC_DOCKER_NS}/fabric-baseos:${THIRD_PARTY_IMAGE_VERSION}
