#!/bin/bash

PREFIX=cnd

export DOCKER_CLIENT_TIMEOUT=300

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

echo "Docker type is $DOCKER_TYPE"

echo
echo 'Starting Couchbase cluster'

echo
echo 'Pulling the most recent images'
docker-compose pull

echo
echo 'Finding consul'

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

echo
echo 'Starting containers'
docker-compose --project-name=$PREFIX up -d --no-recreate --timeout=500

echo
echo 'Scaling couchbase cluster.'
docker-compose --project-name=$PREFIX scale couchbase=3

echo
echo -n 'Initilizing cluster.'

sleep 1.3
COUCHBASERESPONSIVE=0
while [ $COUCHBASERESPONSIVE != 1 ]; do
    echo -n '.'

    RUNNING=$(docker inspect "$PREFIX"_couchbase_1 | json -a State.Running)
    if [ "$RUNNING" == "true" ]
    then
        docker exec -it "$PREFIX"_couchbase_1 couchbase-bootstrap bootstrap
        let COUCHBASERESPONSIVE=1
    else
        sleep 1.3
    fi
done

sleep 30

docker exec -it "$PREFIX"_couchbase_1 couchbase-cli bucket-create -c 127.0.01:8091 -u Administrator -p password \
    --bucket=travel \
    --bucket-type=couchbase \
    --bucket-ramsize=512 \
    --bucket-replica=0

if [ $DOCKER_TYPE = 'sdc' ]
    then
    CBIP="$(sdc-listmachines | json -aH -c "'"$PREFIX"_couchbase_1' == this.name" ips.0)"
    CBPORT="8091"
else
    if [ $DOCKER_TYPE = 'boot2docker' ]
        then
        CBPORT=$(docker inspect --format='{{(index (index .NetworkSettings.Ports "8091/tcp") 0).HostPort}}' "$PREFIX"_couchbase_1)
        CBIP=$(boot2docker ip)
    else
        CBIP="$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' "$PREFIX"_couchbase_1)"
        CBPORT="8091"
    fi
fi
CBDASHBOARD="$CBIP:$CBPORT"

echo
echo 'Couchbase cluster running and bootstrapped'
echo "Dashboard: $CBDASHBOARD"
echo "username=Administrator"
echo "password=password"
