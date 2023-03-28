#!/bin/sh

# This script runs on the test bastion server to initialize and setup the test environment.

rm -rf /var/log/sudo-io

useradd bastion
usermod -s /usr/bin/sudosh bastion
cp /google_authenticator /home/bastion/.google_authenticator
chown -R bastion: /home/bastion
chmod 600 /home/bastion/.google_authenticator
