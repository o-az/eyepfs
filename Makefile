docker-build:
	docker buildx build . --progress 'plain' --file 'Dockerfile' --tag 'ipfs_gateway_proxy'

docker-run:
	docker run --rm -it --name 'ipfs_gateway_proxy' --env IPFS_GATEWAY_HOST='http://127.0.0.1:8080' --env ALLOW_ORIGINS='http://127.0.0.1,https://eyepfs.railway.app,https://tokens.evn.workers.dev' --publish '3031:3031' 'ipfs_gateway_proxy'

railway-deploy:
	RAILWAY_DOCKERFILE_PATH='Dockerfile' railway up --service 'api' --detach --environment 'production'
