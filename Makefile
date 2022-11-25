
DOCKER_REGISTRY=komuw
PROJECT_NAME=redis-cluster
LATEST_COMMIT=$(shell git log -n 1 --pretty=format:%h)
ALTREPO=$(DOCKER_REGISTRY)/$(PROJECT_NAME)
REDIS_VERSION="6.2"

build-image:
	docker ps -aq | xargs docker rm -f;docker volume ls -q | xargs docker volume rm -f | echo ''
	docker build -t "${ALTREPO}:v${REDIS_VERSION}-${LATEST_COMMIT}" .
	# docker push --all-tags $(ALTREPO)


build:
	docker-compose build

up:
	docker-compose up

down:
	docker-compose stop

rebuild:
	docker-compose build --no-cache

bash:
	docker-compose exec redis-cluster /bin/bash

cli:
	docker-compose exec redis-cluster /redis/src/redis-cli -p 7000
