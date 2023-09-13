docker-build:
	docker buildx build . \
		--progress 'plain' \
		--file 'Dockerfile' \
		--tag 'ipfs_gateway_proxy' \
		--platform 'linux/amd64'

docker-run:
	docker run \
		--rm \
		-it \
		--name 'ipfs_gateway_proxy' \
		--env IPFS_GATEWAY_HOST='http://127.0.0.1:8080' \
		--env ALLOW_ORIGINS='*' \
		--env API_KEY="$(API_KEY)" \
		--publish '3031:3031' \
		--platform 'linux/amd64' \
		'ipfs_gateway_proxy'

fly-deploy:
	RAILWAY_DOCKERFILE_PATH='Dockerfile' railway up --service 'api' --detach --environment 'production'

generate-key:
	openssl rand -base64 32
