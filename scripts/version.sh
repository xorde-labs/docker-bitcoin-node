#!/bin/sh

bitcoind --version | awk 'NF{ print $NF }'