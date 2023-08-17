#!/usr/bin/env bash

set -euo pipefail

# https://docs.ipfs.tech/install/run-ipfs-inside-docker/

docker run \
  -it \
  --rm \
  --detach \
  --name ipfs_host \
  --label ipfs_host \
  --volume ipfs_export:/export \
  --volume ipfs_data:/data/ipfs \
  --publish 4001:4001 \
  --publish 4001:4001/udp \
  --publish 127.0.0.1:8080:8080 \
  --publish 127.0.0.1:5001:5001 \
  ipfs/kubo:latest
