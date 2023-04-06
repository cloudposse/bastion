#!/bin/bash

# Generating temp keys
rm -rf fixtures/auth/ida_rsa*
ssh-keygen -q -f fixtures/auth/ida_rsa -N ""
chmod 600 fixtures/auth/ida_rsa

docker compose down
docker compose up --build bastion -d
docker compose exec bastion /scripts/setup.sh
docker compose run --build test /scripts/google_auth_test.sh

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
