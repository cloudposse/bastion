#!/bin/sh
ping -c 1 -w 5 bastion > /dev/null

# Add -vv for debugging.
sshpass \
	-P 'Verification code:' \
	-f ./code \
	ssh bastion@bastion \
	-o StrictHostKeyChecking=no \
	-- echo 'this is a test.'
