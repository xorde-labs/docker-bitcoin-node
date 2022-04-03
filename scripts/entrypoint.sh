#!/bin/sh

CONF="$HOME/.bitcoin/bitcoin.conf"

# Generate bitcoin.conf
$HOME/setup.sh

echo "Loading ${CONF}"
cat $CONF
awk -F\= '{gsub(/"/,"",$2);print "Node parameter " toupper($1) " is set " $2}' ${CONF}

set -ex
exec bitcoind -printtoconsole -conf=$CONF "$@"
