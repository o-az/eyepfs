ARG PLATFORM=amd64
FROM --platform=${PLATFORM} golang:bullseye

ENV NODE_ENV="production"

ENV PORT="3031"

ARG IPFS_GATEWAY_URL
ENV IPFS_GATEWAY_URL=${IPFS_GATEWAY_URL}

ARG IPFS_GATEWAY_HOST
ENV IPFS_GATEWAY_HOST=${IPFS_GATEWAY_HOST}

SHELL [ "/bin/bash", "-o", "pipefail", "-c" ]

WORKDIR /usr/src/app

RUN apt-get --yes update && \
  export DEBIAN_FRONTEND='noninteractive' && \
  apt-get --yes upgrade && \
  apt-get --yes install --no-install-recommends \
  sudo \
  unzip && \
  curl -fsSL https://bun.sh/install | bash && \
  source ~/.bashrc && \
  apt-get --yes autoremove && \
  apt-get --yes clean && \
  rm -rf /var/lib/apt/lists/*

COPY ./scripts/entrypoint.sh ./ipfs.sh ./ipfs-gateway.sh ./src/* /usr/src/app/

RUN chmod +x /usr/src/app/*.sh

ENTRYPOINT ["/usr/src/app/entrypoint.sh"]
