# Voting-smartContracts
## Install Hyperledger Besu
### Prerequisites
 - Docker and Docker-compose
 - Git command line
 - Curl command line
### Install
Clone Hyperledger's Besu quickstart network.
```
git clone https://github.com/PegaSysEng/besu-sample-networks.git
```
Start network in ibft2
```
./run.sh -c ibft2
```

## Deploy contracts using truffle
### Prerequisites
https://www.trufflesuite.com/docs/truffle/getting-started/installation
### Migrate contracts
```
truffle migrate
```