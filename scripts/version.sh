#!/bin/sh

bitcoind --version | awk 'NF{ print $NF }' | head -n 1
