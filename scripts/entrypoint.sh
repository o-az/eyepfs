#!/usr/bin/env bash

set -euo pipefail

/bin/bash ipfs.sh &

sleep 2.69

/bin/bash ipfs-gateway.sh &

sleep 5.73

echo "IPFS Gateway is ready!"

~/.bun/bin/bun run --hot ./index.ts
