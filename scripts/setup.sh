#!/bin/sh

# This script sets up the conf file to be used by the node daemon process. It only has
# an effect if there is no conf file in daemon work directory.
#
# The options it sets can be tweaked by setting environmental variables when creating the docker
# container.
#

set -e

CONF="$HOME/.bitcoin/bitcoin.conf"

if [ ! -e "rpcpassword.txt" ]; then
  tr -cd '[:alnum:]' < /dev/urandom | fold -w30 | head -n1 > rpcpassword.txt
fi;

if [ -z ${ENABLE_WALLET:+x} ]; then
    echo "disablewallet=${ENABLE_WALLET}" >> $CONF
fi;

if [ ! -z ${TESTNET:+x} ]; then
    echo "testnet=${TESTNET}" >> $CONF
fi;

if [ ! -z ${MAX_CONNECTIONS:+x} ]; then
    echo "maxconnections=${MAX_CONNECTIONS}" >> $CONF
fi;

# set ipv4, ipv6 or onion
if [ ! -z ${ONLYNET:+x} ]; then
    echo "onlynet=${ONLYNET}" >> $CONF
fi;

if [ ! -z ${RPC_SERVER:+x} ]; then
	RPC_USER=${RPC_USER:-bitcoinrpc}
	RPC_PASSWORD=${RPC_PASSWORD:-$(cat rpcpassword.txt)}

	echo "server=1" >> $CONF
	echo "rpcbind=0.0.0.0" >> $CONF
	echo "rpcallowip=0.0.0.0/0" >> $CONF
	echo "rpcuser=${RPC_USER}" >> $CONF
	echo "rpcpassword=${RPC_PASSWORD}" >> $CONF
fi;

echo "Initialization completed successfully"
