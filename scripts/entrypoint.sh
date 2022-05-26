#!/bin/sh

alias echo="echo ENTRYPOINT:"

CONFIG_FILE_DEFAULT=${HOME}/.bitcoin/bitcoin.conf
CONFIG_FILE="${CONFIG_FILE:-${CONFIG_FILE_DEFAULT}}"
CONFIG_FILE_DIR=$(dirname "${CONFIG_FILE}")

mkdir -p "${CONFIG_FILE_DIR}"

### Generate bitcoin.conf
$HOME/config.sh ${CONFIG_FILE}

echo "Loading ${CONFIG_FILE}"
echo "-----------------------"
cat "${CONFIG_FILE}"
echo "-----------------------"

set -ex
# shellcheck disable=SC2068
exec bitcoind -printtoconsole -conf="${CONFIG_FILE}" $@
