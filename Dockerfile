ARG DENO_VERSION=1.36.1
FROM denoland/deno:bin-${DENO_VERSION} AS deno_bin

FROM ipfs/kubo:latest AS kubo_binary

FROM debian:stable-slim AS final

ENV PORT="3031"
ENV ENV="production"
ENV IPFS_GATEWAY_HOST="http://127.0.0.1:8080"

COPY --from=kubo_binary /usr/local/bin/ipfs /usr/local/bin/ipfs
COPY --from=deno_bin /deno /usr/local/bin/deno

WORKDIR /app

COPY ./scripts/entrypoint.sh ./src/* /app/

RUN chmod +x /app/entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]
