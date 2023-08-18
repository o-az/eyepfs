# Hosted IPFS Gateway & HTTP Proxy

## Uses

- [ipfs/kubo](https://github.com/ipfs/kubo)
- [bifrost-gateway](https://github.com/ipfs/bifrost-gateway)
- [bun](https://bun.sh/)

## Purpose

Overcome public IPFS gateway limitations, such as [429 Too Many Requests](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/429), by hosting your own IPFS Gateway and HTTP Proxy.

![429 Example](https://github-production-user-asset-6210df.s3.amazonaws.com/23618431/261382276-f08af99b-fad0-4076-afbf-91d41b428147.png)

## Usage

```sh
git clone https://github.com/o-az/eyepfs.git
```

**You have two options to run this:**

- Run everything through `Dockerfile` (recommended),
- Run each service individually

### Run everything through `Dockerfile`:

Build `Dockerfile`:

```sh
docker buildx build . \
  --progress 'plain' \
  --file 'Dockerfile' \
  --tag 'my_ipfs_gateway_proxy'
```

Run the image you just built:

```sh
docker run --rm -it \
  --name 'my_ipfs_gateway_proxy' \
  --env IPFS_GATEWAY_HOST="http://127.0.0.1:8081" \
  --publish '3031:3031' \
  'my_ipfs_gateway_proxy'
```

Smoke test (fetch image):

```sh
curl --location --request GET \
  --url 'http://127.0.0.1:3031/bafybeigdyrzt5sfp7udm7hu76uh7y26nf3efuylqabf3oclgtqy55fbzdi' \
  --output 'image.jpeg'
```
____

### Run each service individually:

```sh
bun start-ipfs
# this runs `start-ipfs-host` in `Makefile`
```

```sh
bun start-ipfs:gateway
# this runs `start-ipfs-gateway` in `Makefile`
```

```sh
bun start-proxy
# this runs `./src/index.ts` which starts the proxy server
```

## Deployment:

anywhere that can run a `Dockerfile` 🐳