#!/bin/sh
ping -c 1 -w 5 bastion # > /dev/null

# Wait for SSH to be available on port 22
max_attempts=10
attempt=1
while [ $attempt -le $max_attempts ]; do
	if nc -z -w 2 bastion 22 2>/dev/null; then
		break
	fi
	if [ $attempt -eq $max_attempts ]; then
		echo "Error: SSH port 22 not available on bastion after $max_attempts attempts" >&2
		exit 1
	fi
	attempt=$((attempt + 1))
	sleep 1
done

# Add -vv for debugging.
sshpass \
	-P 'Verification code:' \
	-f ./code \
	ssh bastion@bastion \
	-o StrictHostKeyChecking=no \
	-- echo 'this is a test.'

