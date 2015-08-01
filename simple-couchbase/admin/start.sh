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
echo 'Starting SSH endpoint'

echo
echo 'Pulling the most recent images'
docker-compose pull

docker-compose --project-name=$PREFIX up -d --no-recreate --timeout=500

if [ $DOCKER_TYPE = 'sdc' ]
    then
    SSHIP="$(sdc-listmachines | json -aH -c "'"$PREFIX"_ssh_1' == this.name" ips.1)"
    SSHPORT="2022"
else
    SSHPORT=$(docker inspect --format='{{(index (index .NetworkSettings.Ports "2022/tcp") 0).HostPort}}' "$PREFIX"_ssh_1)
    if [ $DOCKER_TYPE = 'boot2docker' ]
        then
        SSHIP=$(boot2docker ip)
    else
        SSHIP="localhost"
    fi
fi
SSH="$SSHIP:$SSHPORT"

#cat ~/.ssh/id_rsa.pub | docker exec -i "$PREFIX"_ssh_1 /bin/bash -c "cat >> /root/.ssh/authorized_keys"

#if [ $DOCKER_TYPE = 'sdc' ]
#    then
#    PRIVATE_ID=$(sdc-listnetworks | json -aH -c "'Joyent-SDC-Private' == this.name" id)
#    IDS=$(sdc-listmachines | json -aH -c "this.name.indexOf('${PREFIX}_') === 0" id)
#    for ID in ${IDS//\\n/
#    }
#    do
#       echo "sdc-nics create $PRIVATE_ID $ID"
#    done

#fi

echo
echo 'SSH tunnel is now up'
echo "sshuttle -r root@$SSH 0/0 -vv"
