#!/bin/bash

PREFIX=cnd

BOOT2DOCKER=$(docker info | grep boot2docker)
if [[ $BOOT2DOCKER && ${BOOT2DOCKER-x} ]]
    then
    export DOCKER_TYPE="boot2docker"
else
    SDC=$(docker info | grep SmartDataCenter)
    if [[ $SDC && ${SDC-x} ]]
        then
        export DOCKER_TYPE="sdc"
    else
        export DOCKER_TYPE="default"
    fi
fi

if [ $DOCKER_TYPE = 'sdc' ]
    then
    export CONSUL_IP="$(sdc-listmachines | json -aH -c "'"$PREFIX"_consul_1' == this.name" ips.0)"
    export CONSUL_PORT="8500"
else
    if [ $DOCKER_TYPE = 'boot2docker' ]
        then
        export CONSUL_IP=$(boot2docker ip)
        export CONSUL_PORT=$(docker inspect --format='{{(index (index .NetworkSettings.Ports "8091/tcp") 0).HostPort}}' "$PREFIX"_consul_1)
    else
        export CONSUL_IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' "$PREFIX"_consul_1)
        export CONSUL_PORT="8500"
    fi
fi

docker run -d -e CONSUL_IP=$CONSUL_IP -e CONSUL_PORT=$CONSUL_PORT -m 512m --name "$PREFIX"_cbload_1 corbinu/demo-cb-load

docker exec -it "$PREFIX"_cbload_1 demo-cb-load unpack

docker exec -it "$PREFIX"_cbload_1 cb-load-bootstrap travel
sleep 10
docker exec -it "$PREFIX"_cbload_1 cb-load-bootstrap setup

docker rm -f "$PREFIX"_cbload_1

echo "couchbase loaded"
