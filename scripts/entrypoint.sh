#!/bin/sh

IPFS_GATEWAY_HOST="${IPFS_GATEWAY_HOST:-http://127.0.0.1:8080}"

[ -z "${IPFS_GATEWAY_HOST}" ] && echo "IPFS_GATEWAY_HOST is required" && exit 1

echo "Starting IPFS Gateway..."
ipfs init
ipfs daemon &
sleep 3

echo "IPFS Gateway is ready!"
echo "Starting Deno server..."

IPFS_GATEWAY_HOST="${IPFS_GATEWAY_HOST}" /usr/local/bin/deno run --allow-all --unstable /app/index.ts

tail -f /dev/null
