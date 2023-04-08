#!/bin/sh
ping -c 1 -w 5 bastion

# Add -vv for debugging.
sshpass \
	-P 'Verification code:' \
	-f ./code \
	ssh sshrc_exit_test@bastion \
	-o StrictHostKeyChecking=no \
	-- echo 'this output should never print.'
