#!/bin/bash

CONF="$HOME/.bitcoin/bitcoin.conf"

# Generate bitcoin.conf
setup.sh

if [ $# -gt 0 ]; then
    args=("$@")
else
    args=("-rpcallowip=::/0")
fi

echo "Loading ${CONF}"
awk -F\= '{gsub(/"/,"",$2);print "Node parameter " toupper($1) " is set " $2}' ${CONF}


set -ex
exec bitcoind -printtoconsole "${args[@]}"