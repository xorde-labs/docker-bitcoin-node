# Bitcoin node

[![Docker Build](https://github.com/xorde-nodes/bitcoin-node/actions/workflows/docker-image.yml/badge.svg)](https://github.com/xorde-nodes/bitcoin-node/actions/workflows/docker-image.yml)

### Quick start

```shell
docker run -d -p 8332:8332 -p 8333:8333 --restart unless-stopped ghcr.io/xorde/bitcoin-node:latest
```

Store all settings and blockchain outside docker container:

```shell
docker run -d --name bitcoin-node -v /data1/btc:/root/.bitcoin -p 8332:8332 -p 8333:8333 --restart always -e "ENABLE_WALLET=1" -e "RPC_SERVER=1" ghcr.io/xorde/bitcoin-node:latest
```

Store all settings and blockchain outside docker container and run node on testnet:

```shell
docker run -d --name bitcoin-node -v /data1/btc:/root/.bitcoin -p 8332:8332 -p 8333:8333 --restart always -e "TESTNET=1" -e "RPC_SERVER=1" ghcr.io/xorde/bitcoin-node:latest
```

### Parameters

Available environment variables (to use with docker "-e" argument):

#### Enable Wallet

```dotenv
WALLET_ENABLE=1
```

#### Enable Testnet

```dotenv
TESTNET_ENABLE=1
```

#### Limit maximum network connections

```dotenv
MAX_CONNECTIONS=30
```

#### Enable RPC server

```dotenv
RPC_ENABLE=1
```

#### Set specific username for RPC server

(otherwise `bitcoinrpc` will be used as default)

```dotenv
RPC_USER=user
```

#### Set specific password for RPC server 

(otherwise automatically generated will be used):

```dotenv
RPC_PASSWORD=pa$$word
```
