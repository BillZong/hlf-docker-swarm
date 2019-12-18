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
cp -R bin/* ${VOLUMES_DIR}/bin/
