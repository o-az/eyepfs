#!/usr/bin/env bash

set -euo pipefail

# https://github.com/ipfs/bifrost-gateway/tree/main

BINARY_URL=$(curl 'https://api.github.com/repos/ipfs/bifrost-gateway/releases/latest' | grep '"tarball_url"' | cut -d '"' -f4)

curl --location \
  --request 'GET' \
  --output 'bifrost-gateway.tar.gz' \
  --url "${BINARY_URL}"

rm -rf './bifrost-gateway' &&
  mkdir './bifrost-gateway'

tar --extract \
  --verbose \
  --gzip \
  --file 'bifrost-gateway.tar.gz' \
  --directory './bifrost-gateway' \
  --strip-components 1

export PROXY_GATEWAY_URL="http://127.0.0.1:8080"

cd './bifrost-gateway' &&
  go build

./bifrost-gateway --help

./bifrost-gateway
