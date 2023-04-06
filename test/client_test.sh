#!/bin/sh
ping -c 1 -w 5 bastion

chmod 600 /root/.ssh/ida_rsa

sshpass \
	-P 'Verification code:' \
	-f ./code \
	ssh bastion@bastion \
	-o StrictHostKeyChecking=no \
	-vv \
	-- echo 'this is a test.'
