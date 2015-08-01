#!/bin/bash

PREFIX=cnd

export DOCKER_CLIENT_TIMEOUT=300

echo
echo 'Starting Node Demo head'

echo
echo 'Pulling the most recent images'
docker-compose pull

echo
echo 'Starting containers'
docker-compose --project-name=$PREFIX up -d --no-recreate --timeout=500

echo
echo -n 'consul started.'
