#!/bin/sh

if [ "$1" = 'redis-cluster' ]; then
    IP=$(hostname -I)
    echo " -- IP Before trim: '$IP'"
    IP=$(echo ${IP}) # trim whitespaces
    echo " -- IP Before split: '$IP'"
    IP=${IP%% *} # use the first ip
    echo " -- IP After trim: '$IP'"

    if [ -z "$REDIS_PASSWORD" ]; then
      REDIS_PASSWORD=hello
    fi

    
    INITIAL_PORT=6379
    # If you use less than 3 masters, you get error: `Redis Cluster requires at least 3 master nodes`
    MASTERS=3
    SLAVES_PER_MASTER=1
    # Default to any IPv4 address
    BIND_ADDRESS=0.0.0.0

    max_port=$(($INITIAL_PORT + $MASTERS * ( $SLAVES_PER_MASTER  + 1 ) - 1))
    first_standalone=$(($max_port + 1))

    printf "\n\t max_port: ${max_port}\n"
    printf "\n\t first_standalone: ${first_standalone}\n"

    for port in $(seq $INITIAL_PORT $max_port); do
      mkdir -p /redis-conf/${port}
      mkdir -p /redis-data/${port}

      if [ -e /redis-data/${port}/nodes.conf ]; then
        rm /redis-data/${port}/nodes.conf
      fi

      if [ -e /redis-data/${port}/dump.rdb ]; then
        rm /redis-data/${port}/dump.rdb
      fi

      if [ -e /redis-data/${port}/appendonly.aof ]; then
        rm /redis-data/${port}/appendonly.aof
      fi

      PORT=${port} BIND_ADDRESS=${BIND_ADDRESS} REDIS_PASSWORD=${REDIS_PASSWORD} envsubst < /redis-conf/redis-cluster.tmpl > /redis-conf/${port}/redis.conf
      nodes="$nodes $IP:$port"

    done

    bash /generate-supervisor-conf.sh $INITIAL_PORT $max_port > /etc/supervisor/supervisord.conf

    supervisord -c /etc/supervisor/supervisord.conf
    sleep 3

    echo "Using redis-cli to create the cluster"
    echo "yes" | eval /redis/src/redis-cli --cluster create --cluster-replicas "$SLAVES_PER_MASTER" "$nodes" -a "${REDIS_PASSWORD}"

    tail -f /var/log/supervisor/redis*.log
else
  exec "$@"
fi
