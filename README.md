# Bitcoin node

[![Docker Build](https://github.com/xorde-nodes/bitcoin-node/actions/workflows/docker-image.yml/badge.svg)](https://github.com/xorde-nodes/bitcoin-node/actions/workflows/docker-image.yml)

This is a dockerized, built from scratch bitcoin node.


### Quick start

#### Standalone Docker

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

#### Docker Compose

```shell
git clone https://github.com/xorde-nodes/bitcoin-node.git
cd bitcoin-node
cp example.env .env
# now please edit .env file to your choice, save it, and continue:
# you can skip editing .env file, and leave it unchanged 
# as it is pre-configured to run on testnet
docker compose up -d
```

Example .env:

```dotenv
WALLET_ENABLE=1
NETWORK=testnet
MAX_CONNECTIONS=50
RPC_ENABLE=1
RPC_USER=rpc-user
RPC_PASSWORD=rpc-password
RPC_ALLOW=0.0.0.0/0
PORT=8333
RPC_PORT=8332
```

### Parameters

Available environment variables (to use with docker "-e" argument):

#### Configuration File

Default: `${HOME}/.bitcoin/bitcoin.conf`

> Please note, that startup sequence scripts will create specified config file if it doesn't exist

```dotenv
CONFIG_FILE=/path/bitcoin.conf
```

#### Enable Wallet

Default: `false`

```dotenv
WALLET_ENABLE=Y
```

#### Select Network

Default: `mainnet`

Possible values: testnet, signet, regtest

```dotenv
NETWORK=mainnet
```

#### Enable Socks5 Proxy

Default: empty

```dotenv
SOCKS5_PROXY=127.0.0.1:9050
```

#### Limit maximum network connections

Default: `125`

```dotenv
MAX_CONNECTIONS=30
```

#### Enable RPC server

Default: `false`

```dotenv
RPC_ENABLE=Y
```

#### Set specific username for RPC server

Default: `bitcoinrpc`

```dotenv
RPC_USER=user
```

#### Set specific password for RPC server 

Default: automatically generated, and will be printed to console

```dotenv
RPC_PASSWORD=pa$$word
```
