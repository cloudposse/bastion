#!/bin/bash

red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`

# Generating temp keys
rm -rf fixtures/auth/ida_rsa*
ssh-keygen -q -f fixtures/auth/ida_rsa -N ""
chmod 600 fixtures/auth/ida_rsa

docker-compose down
docker-compose up --build bastion -d
docker-compose exec bastion /scripts/setup.sh
docker-compose run --build test /scripts/google_auth_test.sh

retVal=$?

if [ $retVal -ne 0 ]; then
  echo "${red}* Google Authenticator/SSH Test Failed${reset}"
  exit $retVal
else
  echo "${green}* Google Authenticator/SSH Test Succeeded${reset}"
fi


docker-compose exec bastion ls /var/log/sudo-io/00/00/01/

retVal=$?

if [ $retVal -ne 0 ]; then
  echo "${red}* sudosh Audit Failed - no logs created!${reset}"
  exit $retVal
else
  echo "${green}* sudosh Audit Test Succeeded${reset}"
fi


docker-compose exec bastion curl https://hooks.slack.com

retVal=$?

if [ $retVal -ne 0 ]; then
  echo "${red}* Failure to connect to slack API.${reset}"
  exit $retVal
else
  echo "${green}* Slack API Connection Test Succeeded${reset}"
fi

export SSHRC_KILL_OUTPUT=`docker-compose run --build test /scripts/sshrc_kill_test.sh`

if [[ "$SSHRC_KILL_OUTPUT" == *"this output should never print"* ]]; then
  echo "${red}* Failure to quit after non-zero exit code in sshrc${reset}"
  exit 1
else
  echo "${green}* sshrc non-zero exit code quit Succeeded${reset}"
fi

