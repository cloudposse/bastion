#!/bin/bash

docker-compose kill
docker-compose rm -v
docker volume rm compose_etc
docker volume rm compose_home
docker-compose up -d
docker-compose logs -f
