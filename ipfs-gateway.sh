#!/usr/bin/env bash

set -euo pipefail

# https://github.com/ipfs/bifrost-gateway/tree/main

docker run \
  -it \
  --rm \
  --detach \
  --name ipfs_gateway \
  --label ipfs_gateway \
  --net=host \
  --env PROXY_GATEWAY_URL='http://127.0.0.1:8080' \
  --env GRAPH_BACKEND='true' \
  --env BLOCK_CACHE_SIZE='1024' \
  ipfs/bifrost-gateway:release
