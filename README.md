Quick start guide
-----------------

On a docker server issue this command:
```shell
docker run -d -p 8332:8332 -p 8333:8333 --restart always xorde/bitcoin-node:latest

```
For a full node with wallet support and JSON RPC server issue this command:
```shell
docker run -d --name bitcoin-node -p 8332:8332 -p 8333:8333 --restart always -e "ENABLE_WALLET=1" -e "RPC_SERVER=1" xorde/bitcoin-node:latest
```

Store all settings and blockchain outside docker container:
```shell
docker run -d --name bitcoin-node -v /data1/btc:/root/.bitcoin -p 8332:8332 -p 8333:8333 --restart always -e "ENABLE_WALLET=1" -e "RPC_SERVER=1" xorde/bitcoin-node:latest
```

Store all settings and blockchain outside docker container and run node on testnet:
```shell
docker run -d --name bitcoin-node -v /data1/btc:/root/.bitcoin -p 8332:8332 -p 8333:8333 --restart always -e "TESTNET=1" -e "ENABLE_WALLET=1" -e "RPC_SERVER=1" xorde/bitcoin-node:latest
```

Available environment variables (to use with docker "-e" argument):

Enable wallet:
ENABLE_WALLET=1

Enable testnet network:
TESTNET=1

Limit connections to specific IP version 
(this will remove warnings for ipv6 connections):
ONLYNET=ipv4

Limit maximum network connections:
MAX_CONNECTIONS=30

Enable RPC server:
RPC_SERVER=1

Set specific username for RPC server:
(otherwise rpcuser will be used as default):
RPC_USER=user

Set specific password for RPC server 
(otherwise automatically generated will be used):
RPC_PASSWORD=pa$$word
