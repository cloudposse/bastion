#!/bin/bash


# test script to control starting and running everything in right order.

docker compose up --build bastion -d
docker compose exec bastion /setup.sh
docker compose run --build test /client_test.sh

retVal=$?

if [ $retVal -ne 0 ]; then
  echo "* Google Authenticator/SSH Test Failed"
  exit $retVal
else
  echo "* Google Authenticator/SSH Test Succeeded"
fi 


docker compose exec bastion ls /var/log/sudo-io/00/00/01/ 

retVal=$?

if [ $retVal -ne 0 ]; then
  echo "* sudosh Audit Failed - no logs created!"
  exit $retVal
else
  echo "* sudosh Audit Test Succeeded"
fi


docker compose exec bastion curl https://hooks.slack.com

retVal=$?

if [ $retVal -ne 0 ]; then
  echo "* Failure to connect to slack API."
  exit $retVal
else
  echo "* Slack API Connection Test Succeeded"
fi


