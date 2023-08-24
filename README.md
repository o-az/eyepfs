# Hosted IPFS Gateway & HTTP Proxy

## Purpose

Overcome public IPFS gateway limitations, such as [429 Too Many Requests](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/429), by hosting your own IPFS Gateway and HTTP Proxy.

![429 Example](https://github-production-user-asset-6210df.s3.amazonaws.com/23618431/261382276-f08af99b-fad0-4076-afbf-91d41b428147.png)

## Usage

```sh
git clone https://github.com/o-az/eyepfs.git
```

#### Build **`Dockerfile`**

```sh
docker buildx build . \
  --progress 'plain' \
  --file 'Dockerfile' \
  --platform 'linux/amd64' \
  --tag 'ipfs_gateway_proxy'

# or `make docker-build`
```

#### Run the image you just built

```sh
docker run \
  --rm \
  -it \
  --name 'ipfs_gateway_proxy' \
  --env IPFS_GATEWAY_HOST='http://127.0.0.1:8080' \
  --env ALLOW_ORIGINS='*' \
  --publish '3031:3031' \
  --platform 'linux/amd64' \
  'ipfs_gateway_proxy'

# or `make docker-run`
```

#### Run a quick test

<sup> _note: btw it may need a few seconds if it's your first time, no more than 6. So if request fail, just retry_</sup>

Open this in browser: <http://127.0.0.1:3031/bafybeigdyrzt5sfp7udm7hu76uh7y26nf3efuylqabf3oclgtqy55fbzdi>

or run this:

```sh
curl --location --request GET \
  --url 'http://127.0.0.1:3031/bafybeigdyrzt5sfp7udm7hu76uh7y26nf3efuylqabf3oclgtqy55fbzdi' \
  --output '/tmp/ipfs_proxy_image.jpeg' && \
  stat '/tmp/ipfs_proxy_image.jpeg'
```

Restricting access to your gateway is as simple as setting `ALLOW_ORIGINS` to a comma separated list of allowed origins. Example:

```sh
docker run \
  --rm \
  -it \
  --name 'ipfs_gateway_proxy' \
  --env IPFS_GATEWAY_HOST='http://127.0.0.1:8080' \
  --env ALLOW_ORIGINS='http://example.com,http://example.org' \
  --publish '3031:3031' \
  'ipfs_gateway_proxy'
```

## Deployment

anywhere that can run a **`Dockerfile`** 🐳

[**`Railway.app`**](https://railway.app/)

```sh
RAILWAY_DOCKERFILE_PATH=Dockerfile railway up --service 'api' --detach --environment 'production'
```

[**`fly.io`**](https://fly.io/)

```sh
fly deploy --app='ipfs_gateway' --dockerfile Dockerfile --remote-only --detach --build-arg PORT=3031 --env IPFS_PROFILE='server' --env IPFS_GATEWAY_HOST='http://127.0.0.1:8080' --env ALLOW_ORIGINS='*'
```

## Upcoming Features

- [x] 🔨 (`CORS`) configuration,
- [x] (`Kubo`) disable all methods but `GET` and `HEAD`, and `OPTIONS` for CORS,
- [x] (`Kubo`) set `Swarm#ConnMgr#Type` to `"none"` (disable all swarm connections),
- [ ] (`CI`) workflow publish image to Docker Hub & GitHub Container Registry,
- [ ] (`CI`) Generate a simple performance report on push,
- [ ] Got any ideas? [Let's chat](https://github.com/o-az/eyepfs/issues/new)

If an item has 🔨 it means it's configurable through env variables
