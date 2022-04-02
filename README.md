Quick start guide
-----------------

On a docker server issue this command:
# docker run -d -p 8332:8332 -p 8333:8333 --restart always xorde/bitcoin-node:latest

For a full node with wallet support and JSON RPC server issue this command:
# docker run -d --name bitcoin-node -p 8332:8332 -p 8333:8333 --restart always -e "ENABLE_WALLET=1" -e "RPC_SERVER=1" xorde/bitcoin-node:latest

Store all settings and blockchain outside docker container:
# docker run -d --name bitcoin-node -v /data1/btc:/root/.bitcoin -p 8332:8332 -p 8333:8333 --restart always -e "ENABLE_WALLET=1" -e "RPC_SERVER=1" xorde/bitcoin-node:latest

Store all settings and blockchain outside docker container and run node on testnet:
# docker run -d --name bitcoin-node -v /data1/btc:/root/.bitcoin -p 8332:8332 -p 8333:8333 --restart always -e "TESTNET=1" -e "ENABLE_WALLET=1" -e "RPC_SERVER=1" xorde/bitcoin-node:latest

Availabe environment variables (to use with docker "-e" argument):

To enable wallet:
ENABLE_WALLET=1

To work on a testnet network of a blockchain:
TESTNET=1

To limit connections to specific IP type (this will remove unneseccary warnings for ipv6 connections):
ONLYNET=ipv4

To limit maximum network connections:
MAX_CONNECTIONS=30

To enable RPC server:
RPC_SERVER=1

To set specific username for RPC server (otherwise rpcuser will be used as default):
RPC_USER=user

To set specific password for RPC server (otherwise automatically generated will be used):
RPC_PASSWORD=pa$$word
