#!/usr/bin/env bash

set -euo pipefail

# https://docs.ipfs.tech/install/command-line/#install-official-binary-distributions

BINARY_URL=$(curl --silent 'https://api.github.com/repos/ipfs/kubo/releases/latest' | grep 'browser_download_url' | grep 'linux-amd64.tar.gz' | head --lines 1 | cut -d '"' -f 4)

curl --location \
  --request 'GET' \
  --output 'kubo-source.tar.gz' \
  --url "${BINARY_URL}"

tar --extract \
  --verbose \
  --gzip \
  --file 'kubo-source.tar.gz'

cd 'kubo'

sudo bash './install.sh'

ipfs --version

ipfs init

ipfs daemon
