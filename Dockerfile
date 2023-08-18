FROM golang:bullseye

ENV NODE_ENV="production"

ENV PORT="3031"

ARG IPFS_GATEWAY_URL
ENV IPFS_GATEWAY_URL=${IPFS_GATEWAY_URL}

ARG IPFS_GATEWAY_HOST
ENV IPFS_GATEWAY_HOST=${IPFS_GATEWAY_HOST}

WORKDIR /usr/src/app

RUN apt-get --yes update && \
  export DEBIAN_FRONTEND='noninteractive' && \
  apt-get --yes upgrade && \
  apt-get --yes install --no-install-recommends \
  git \
  tar \
  bash \
  sudo \
  curl \
  unzip && \
  apt-get --yes autoremove && \
  apt-get --yes clean && \
  rm -rf /var/lib/apt/lists/*

SHELL [ "/bin/bash", "-o", "pipefail", "-c" ]

COPY ./scripts/entrypoint.sh ./ipfs.sh ./ipfs-gateway.sh ./tsconfig.json ./package.json ./bun.lockb ./src/* /usr/src/app/

#
# install bun
RUN curl -fsSL https://bun.sh/install | bash && \
  source ~/.bashrc && \
#
# ensure bash scripts are executable
  chmod +x /usr/src/app/*.sh

ENTRYPOINT ["/usr/src/app/entrypoint.sh"]
