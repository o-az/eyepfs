# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
# Build `Dockerfile` and run container (recommended)  #

build-all:
	docker buildx build . \
		--progress 'plain' \
		--file 'Dockerfile' \
		--tag 'my_ipfs_gateway_proxy'

run-all:
	docker run --rm -it \
		--name 'my_ipfs_gateway_proxy' \
		--env IPFS_GATEWAY_HOST="http://127.0.0.1:8081" \
		--publish '3031:3031' \
		'my_ipfs_gateway_proxy'

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
# Run services individually (See `Readme.md` for more) 			#
# You can ignore these if you're running the above commands #

start-ipfs-host:
	docker run \
		-it \
		--rm \
		--detach \
		--name 'ipfs_host' \
		--label 'ipfs_host' \
		--volume 'ipfs_export:/export' \
		--volume 'ipfs_data:/data/ipfs' \
		--publish '4001:4001' \
		--publish '4001:4001/udp' \
		--publish '127.0.0.1:8080:8080' \
		--publish '127.0.0.1:5001:5001' \
		'ipfs/kubo:latest'


start-ipfs-gateway:
	docker run \
		-it \
		--rm \
		--detach \
		--name 'ipfs_gateway' \
		--label 'ipfs_gateway' \
		--network 'host' \
		--env PROXY_GATEWAY_URL='http://127.0.0.1:8080' \
		--env GRAPH_BACKEND='true' \
		--env BLOCK_CACHE_SIZE='1024' \
		'ipfs/bifrost-gateway:release'