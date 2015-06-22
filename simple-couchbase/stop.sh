#!/bin/bash

PREFIX=snd

echo
echo 'Stoping containers'
docker-compose --project-name=$PREFIX stop


echo
echo 'Removing containers'
docker-compose --project-name=$PREFIX rm
