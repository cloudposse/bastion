#!/bin/sh

# This script runs on the test bastion server to initialize and setup the test environment.
syslogd

# Setup expect for google auth test
apk update
apk add expect

rm -rf /var/log/sudo-io

useradd -m bastion
usermod -s /usr/bin/sudosh bastion
cp /auth/google_authenticator /home/bastion/.google_authenticator
chmod 600 /home/bastion/.google_authenticator
mkdir /home/bastion/.ssh
cp /auth/ida_rsa.pub /home/bastion/.ssh/authorized_keys
chown -R bastion: /home/bastion

# setup ejected user

useradd -m sshrc_exit_test
usermod -s /usr/bin/sudosh sshrc_exit_test
cp /auth/google_authenticator /home/sshrc_exit_test/.google_authenticator
chmod 600 /home/sshrc_exit_test/.google_authenticator
mkdir /home/sshrc_exit_test/.ssh
cp /auth/ida_rsa.pub /home/sshrc_exit_test/.ssh/authorized_keys
chown -R sshrc_exit_test: /home/sshrc_exit_test

echo "Setup complete"
