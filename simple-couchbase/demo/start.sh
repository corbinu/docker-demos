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

echo 'Starting Demo'

echo
echo 'Pulling the most recent images'
docker-compose pull

if [ $DOCKER_TYPE = 'sdc' ]
    then
    export CONSUL_IP="$(sdc-listmachines | json -aH -c "'"$PREFIX"_consul_1' == this.name" ips.0)"
    export CONSUL_PORT="8500"
else
    if [ $DOCKER_TYPE = 'boot2docker' ]
        then
        export CONSUL_IP=$(boot2docker ip)
        export CONSUL_PORT=$(docker inspect --format='{{(index (index .NetworkSettings.Ports "8500/tcp") 0).HostPort}}' "$PREFIX"_consul_1)
    else
        export CONSUL_IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' "$PREFIX"_consul_1)
        export CONSUL_PORT="8500"
    fi
fi

echo
echo 'Starting containers'
docker-compose --project-name=$PREFIX up -d --no-recreate --timeout=150

sleep 1.3
DEMORESPONSIVE=0
while [ $DEMORESPONSIVE != 1 ]; do
    echo -n '.'

    RUNNING=$(docker inspect "$PREFIX"_demo_1 | json -a State.Running)
    if [ "$RUNNING" == "true" ]
    then
        let DEMORESPONSIVE=1
    else
        sleep 1.3
    fi
done
echo

if [ $DOCKER_TYPE = 'sdc' ]
    then
    DEMOIP="$(sdc-listmachines | json -aH -c "'"$PREFIX"_demo_1' == this.name" ips.1)"
    DEMOPORT="3000"
else
    DEMOPORT=$(docker inspect --format='{{(index (index .NetworkSettings.Ports "3000/tcp") 0).HostPort}}' "$PREFIX"_demo_1)
    if [ $DOCKER_TYPE = 'boot2docker' ]
        then
        DEMOIP=$(boot2docker ip)
    else
        DEMOIP="localhost"
    fi
fi
DEMO="$DEMOIP:$DEMOPORT"

docker exec -it "$PREFIX"_demo_1 demo-bootstrap setup

echo
echo 'Demo should be coming up'
echo "UI: $DEMO"

docker exec -it "$PREFIX"_demo_1 demo-bootstrap production
`open http://$DEMO`
