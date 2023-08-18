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