#!/bin/sh

if [ "$1" = 'redis-cluster' ]; then
    # Allow passing in cluster IP by argument or environmental variable
    IP="${2:-$IP}"

    if [ -z "$IP" ]; then # If IP is unset then discover it
        IP=$(hostname -I)
    fi

    echo " -- IP Before trim: '$IP'"
    IP=$(echo ${IP}) # trim whitespaces
    echo " -- IP Before split: '$IP'"
    IP=${IP%% *} # use the first ip
    echo " -- IP After trim: '$IP'"

    if [ -z "$INITIAL_PORT" ]; then # Default to port 7000
      INITIAL_PORT=7000
    fi

    if [ -z "$MASTERS" ]; then # Default to 3 masters
      MASTERS=3
    fi

    
    SLAVES_PER_MASTER=1
    # Default to any IPv4 address
    BIND_ADDRESS=0.0.0.0

    max_port=$(($INITIAL_PORT + $MASTERS * ( $SLAVES_PER_MASTER  + 1 ) - 1))
    first_standalone=$(($max_port + 1))
    if [ "$STANDALONE" = "true" ]; then
      STANDALONE=2
    fi
    if [ ! -z "$STANDALONE" ]; then
      max_port=$(($max_port + $STANDALONE))
    fi

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

      if [ "$port" -lt "$first_standalone" ]; then
        PORT=${port} BIND_ADDRESS=${BIND_ADDRESS} envsubst < /redis-conf/redis-cluster.tmpl > /redis-conf/${port}/redis.conf
        nodes="$nodes $IP:$port"
      else
        PORT=${port} BIND_ADDRESS=${BIND_ADDRESS} envsubst < /redis-conf/redis.tmpl > /redis-conf/${port}/redis.conf
      fi

    done

    bash /generate-supervisor-conf.sh $INITIAL_PORT $max_port > /etc/supervisor/supervisord.conf

    supervisord -c /etc/supervisor/supervisord.conf
    sleep 3

    #
    ## Check the version of redis-cli and if we run on a redis server below 5.0
    ## If it is below 5.0 then we use the redis-trib.rb to build the cluster
    #
    /redis/src/redis-cli --version | grep -E "redis-cli 3.0|redis-cli 3.2|redis-cli 4.0"

    if [ $? -eq 0 ]
    then
      echo "Using old redis-trib.rb to create the cluster"
      echo "yes" | eval ruby /redis/src/redis-trib.rb create --replicas "$SLAVES_PER_MASTER" "$nodes"
    else
      echo "Using redis-cli to create the cluster"
      echo "yes" | eval /redis/src/redis-cli --cluster create --cluster-replicas "$SLAVES_PER_MASTER" "$nodes"
    fi

    tail -f /var/log/supervisor/redis*.log
else
  exec "$@"
fi
