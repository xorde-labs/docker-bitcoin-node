#!/bin/sh

CONFIG_FILE=$1

set -e
alias echo="echo CONFIG:"

if [ -f "${CONFIG_FILE}" ]; then
  echo "[${CONFIG_FILE}] already exists. Exiting..."
  exit 0
else
  echo "[${CONFIG_FILE}] doesn't exist. Initializing..."
  printf "# Generated config: START -------------\n\n" > "${CONFIG_FILE}"
fi

### Socks5 proxy:
if [ -n "${SOCKS5_PROXY+1}" ]; then
  echo "Enabling proxy ${SOCKS5_PROXY}"
  printf "proxy=${SOCKS5_PROXY}\n" >> "${CONFIG_FILE}"
fi

### Enable wallet:
if printf "${WALLET_ENABLE}" | grep -q "[Yy1]"; then
  export WALLET_NAME=default_wallet
  echo "Enabling wallet..."
  bitcoin-wallet -wallet=${WALLET_NAME} create && echo "Wallet [${WALLET_NAME}] created"
  printf "wallet=${WALLET_NAME}\n" >> "${CONFIG_FILE}"
fi

### Enable txindex:
if printf "${TXINDEX_ENABLE}" | grep -q "[Yy1]"; then
  echo "Enabling txindex..."
  printf "txindex=1\n" >> "${CONFIG_FILE}"
fi

### Setting up max connections:
if [ -n "${MAX_CONNECTIONS+1}" ]; then
  echo "Max connections ${MAX_CONNECTIONS}"
  printf "maxconnections=${MAX_CONNECTIONS}\n" >> "${CONFIG_FILE}"
fi

### Switch to network:
if [ -n "${NETWORK+1}" ]; then
  echo "Configuring network..."
  case "${NETWORK}" in
    mainnet)
      echo "Network is mainnet"
      NETWORK_SECTION="main"
      ;;
    testnet)
      echo "Network is testnet"
      printf "testnet=1\n" >> "${CONFIG_FILE}"
      NETWORK_SECTION="test"
      ;;
    signet)
      echo "Network is signet"
      printf "signet=1\n" >> "${CONFIG_FILE}"
      NETWORK_SECTION="signet"
      ;;
    regtest)
      echo "Network is regtest"
      printf "regtest=1\n" >> "${CONFIG_FILE}"
      NETWORK_SECTION="regtest"
      ;;
    *)
      echo "Unknown network selected: ${NETWORK}... Defaulting to testnet"
      printf "testnet=1\n" >> "${CONFIG_FILE}"
      NETWORK_SECTION="test"
      ;;
  esac
fi

### Setting up RPC server:
if printf "${RPC_ENABLE}" | grep -q "[Yy1]"; then
  echo "Enabling RPC server..."
  RPC_PASSWORD=${RPC_PASSWORD:-$(tr -cd '[:alnum:]' < /dev/urandom | fold -w30 | head -n1)}
  echo "Using password ${RPC_PASSWORD}"
  ENCRYPTED_PASSWORD=$(./rpcpasswd.py ${RPC_PASSWORD:-})
	RPC_AUTH="${RPC_USER:-bitcoinrpc}:${ENCRYPTED_PASSWORD}"

	printf "server=1\n" >> "${CONFIG_FILE}"
	printf "rpcallowip=${RPC_ALLOW:-0.0.0.0/0}\n" >> "${CONFIG_FILE}"
	printf "rpcauth=${RPC_AUTH}\n" >> "${CONFIG_FILE}"
	printf "\n[${NETWORK_SECTION:-main}]\nrpcport=8332\nrpcbind=${RPC_BIND:-0.0.0.0}" >> "${CONFIG_FILE}"
fi

echo "Config initialization completed successfully (${CONFIG_FILE})"
printf "\n\n# Generated config: END -------------\n" >> "${CONFIG_FILE}"
