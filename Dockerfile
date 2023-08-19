ARG DENO_VERSION=1.36.1
FROM denoland/deno:bin-${DENO_VERSION} AS deno_bin

FROM ipfs/kubo:latest AS kubo_binary
FROM ipfs/bifrost-gateway:latest AS bifrost_binary

FROM debian:stable-slim AS final

ENV PORT="3031"
ENV ENV="production"
ENV IPFS_GATEWAY_HOST="http://127.0.0.1:8081"
ENV PROXY_GATEWAY_URL="http://127.0.0.1:8080"

# copy ipfs/kubo
COPY --from=kubo_binary /usr/local/bin/ipfs /usr/local/bin/ipfs
# # copy ipfs/bifrost-gateway
COPY --from=bifrost_binary /usr/local/bin/bifrost-gateway /usr/local/bin/bifrost-gateway
# # copy deno binary
COPY --from=deno_bin /deno /usr/local/bin/deno

WORKDIR /app

COPY ./scripts/entrypoint.sh ./src/* /app/

RUN chmod +x /app/entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]
