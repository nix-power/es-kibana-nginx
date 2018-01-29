#!/bin/bash

# Create internal network and volumes for the cluster

docker network inspect esnet --format {{.Name}} 2>/dev/null | grep esnet
if [[ $? -ne 0 ]]; then
  docker network create --driver bridge --subnet 10.212.0.0/28 esnet
fi

docker volume inspect es1-data --format {{.Name}} 2>/dev/null | grep es1-data
if [[ $? -ne 0 ]]; then
  docker volume create --name es1-data
fi

docker volume inspect es1-data --format {{.Name}} 2>/dev/null | grep es2-data
if [[ $? -ne 0 ]]; then
  docker volume create --name es2-data
fi
