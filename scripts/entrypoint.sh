#!/bin/sh

IPFS_GATEWAY_HOST="${IPFS_GATEWAY_HOST:-http://127.0.0.1:8081}"
PROXY_GATEWAY_URL="${PROXY_GATEWAY_URL:-http://127.0.0.1:8080}"

[ -z "${IPFS_GATEWAY_HOST}" ] && echo "IPFS_GATEWAY_HOST is required" && exit 1
[ -z "${PROXY_GATEWAY_URL}" ] && echo "PROXY_GATEWAY_URL is required" && exit 1

echo "Starting IPFS Gateway..."

ipfs init

ipfs daemon &

sleep 2.69

bifrost-gateway --help

bifrost-gateway &

sleep 3

echo "IPFS Gateway is ready!"
echo "Starting Deno server..."

IPFS_GATEWAY_HOST="${IPFS_GATEWAY_HOST}" /usr/local/bin/deno run --allow-all --unstable /app/index.ts

tail -f /dev/null
