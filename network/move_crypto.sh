source ${PWD}/.env

# recreate the directories
rm -rf mkdir ${VOLUMES_DIR}/*
mkdir -p ${VOLUMES_DIR}/chaincode
mkdir -p ${VOLUMES_DIR}/certs
mkdir -p ${VOLUMES_DIR}/bin
mkdir -p ${VOLUMES_DIR}/fabric-src/hyperledger

if [ ! -d ../../fabric ]; then
    echo "downloading the fabric src..."
    git clone https://github.com/hyperledger/fabric ../../fabric
fi
cp -r ../../fabric ${VOLUMES_DIR}/fabric-src/hyperledger/
cd ${VOLUMES_DIR}/fabric-src/hyperledger/fabric
git checkout ${FABRIC_VERSION}
# rm -rf .git # keep it small enough

cd -
cp -R crypto-config ${VOLUMES_DIR}/certs/
cp -R config ${VOLUMES_DIR}/certs/
cp -R ../chaincodes/* ${VOLUMES_DIR}/chaincode/

function downloadBinary() {
    binaryFileName=hyperledger-fabric-$FABRIC_IMAGE_ARCH-$FABRIC_IMAGE_VERSION.tar.gz
    if [ ! -f ../../$binaryFileName ]; then
        curl -LO https://github.com/hyperledger/fabric/releases/download/$FABRIC_VERSION/$binaryFileName
        mv $binaryFileName ../../
    fi
    tar -zxf ../../$binaryFileName
}

# download binary neccessary
if [ ! -f bin/configtxgen ]; then
    downloadBinary
else
    # check version
    chmod +x bin/configtxgen
    ver=`./bin/configtxgen --version | grep $FABRIC_IMAGE_VERSION`
    # echo $ver
    if [ "$ver" = "" ]; then
        downloadBinary
    fi
fi

chmod +x bin/*
cp -R bin/* ${VOLUMES_DIR}/bin/
