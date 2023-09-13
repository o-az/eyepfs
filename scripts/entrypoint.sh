#!/bin/sh

IPFS_GATEWAY_HOST="${IPFS_GATEWAY_HOST:-http://127.0.0.1:8080}"
ALLOW_ORIGINS="${ALLOW_ORIGINS:?ALLOW_ORIGINS is required}"
API_KEY="${API_KEY:?API_KEY is required}"

[ -z "${IPFS_GATEWAY_HOST}" ] && echo "IPFS_GATEWAY_HOST is required" && exit 1
[ -z "${ALLOW_ORIGINS}" ] && echo "ALLOW_ORIGINS is required" && exit 1
[ -z "${API_KEY}" ] && echo "API_KEY is required" && exit 1

echo "Starting IPFS Gateway..."
ipfs init
ipfs daemon &
sleep 3

echo "IPFS Gateway is ready!"

ipfs config Swarm.ConnMgr.Type "none"
ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin "[\"${ALLOW_ORIGINS}\"]"
ipfs config --json API.HTTPHeaders.Access-Control-Allow-Methods "[\"HEAD\", \"GET\", \"OPTIONS\"]"

ipfs config --json show

echo "Starting go server..."

/app/proxy_app

tail -f /dev/null
