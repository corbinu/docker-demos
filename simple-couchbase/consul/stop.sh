#!/bin/bash

PREFIX=cnd

export DOCKER_CLIENT_TIMEOUT=300

docker-compose --project-name=$PREFIX stop

docker-compose --project-name=$PREFIX rm
