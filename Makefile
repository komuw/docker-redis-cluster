
DOCKER_REGISTRY=komuw
PROJECT_NAME=redis-cluster
LATEST_COMMIT=$(shell git log -n 1 --pretty=format:%h)
ALTREPO=$(DOCKER_REGISTRY)/$(PROJECT_NAME)
REDIS_VERSION="6.2"

build:
	docker ps -aq | xargs docker rm -f;docker volume ls -q | xargs docker volume rm -f | echo ''
	docker build -t "${ALTREPO}:v${REDIS_VERSION}-${LATEST_COMMIT}" .
	docker push --all-tags $(ALTREPO)
