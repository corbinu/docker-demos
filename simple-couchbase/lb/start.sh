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
echo 'Starting Demo Load balancer'

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
echo -n 'lbs started.'

STAGING=$(sdc-listmachines | json -aH -c "'ds_lbstaging_1' == this.name" ips.1)
PRODUCTION=$(sdc-listmachines | json -aH -c "'ds_lbproduction_1' == this.name" ips.1)
echo "Staging is now: $STAGING"
echo "Production is now: $PRODUCTION"
