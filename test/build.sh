#!/bin/bash

export TERM=linux

red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`

docker -v
docker-compose -v

docker compose build
