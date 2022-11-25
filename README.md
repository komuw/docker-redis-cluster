# docker-redis-cluster

[![Docker Stars](https://img.shields.io/docker/stars/grokzen/redis-cluster.svg)](https://hub.docker.com/r/grokzen/redis-cluster/)
[![Docker Pulls](https://img.shields.io/docker/pulls/grokzen/redis-cluster.svg)](https://hub.docker.com/r/grokzen/redis-cluster/)
[![Build Status](https://travis-ci.org/Grokzen/docker-redis-cluster.svg?branch=master)](https://travis-ci.org/Grokzen/docker-redis-cluster)

Docker image with redis built and installed from source and a cluster is built.

Run:
```
make build
```

**TODO: look at;**      
- https://github.com/phuongdm1987/docker-redis-cluster 
- https://github.com/Grokzen/docker-redis-cluster/issues/54
- https://github.com/Grokzen/docker-redis-cluster/discussions/108

To find all redis-server releases see them here https://github.com/antirez/redis/releases


## What this repo and container IS

This repo exists as a resource to make it quick and simple to get a redis cluster up and running with no fuzz or issues with mininal effort.


## What this repo and container IS NOT

This container that i have built is not supposed to be some kind of production container.


## Redis instances inside the container

The cluster is 6 redis instances running with 3 master & 3 slaves, one slave for each master. They run on ports 6379 to 6384.

This image requires at least `Docker` version 1.10 but the latest version is recommended.


# Important for Mac users
TODO



# Usage

```sh
make build

docker \
  run \
  -it \
  -p 6379-6384:6379-6384 \
  -e REDIS_PORT=6379 \
  -e REDIS_PASSWORD="what43Is*skHSGs" \
  komuw/redis-cluster:v6.2-87c664e
```

## IPv6 support

TODO


# License

This repo is using the MIT LICENSE.

You can find it in the file [LICENSE](LICENSE)
