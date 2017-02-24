export DOCKER_IMAGE ?= cloudposse/$(APP)
export DOCKER_TAG ?= dev
export DOCKER_IMAGE_NAME ?= $(DOCKER_IMAGE):$(DOCKER_TAG)
export DOCKER_BUILD_FLAGS = 

include $(shell curl --silent -O "https://raw.githubusercontent.com/cloudposse/build-harness/master/templates/Makefile.build-harness"; echo Makefile.build-harness)

COPYRIGHT_SOFTWARE_DESCRIPTION := A secure Bastion host implemented as Docker Container running Alpine Linux with Google Authenticator & DUO MFA support

run: 
	ssh-keygen -R '[localhost]:1234'
	docker run -it -p1234:22 -v ~/.ssh/:/root/.ssh/ --env-file=../.secrets -e MFA_PROVIDER=google-authenticator --entrypoint=/bin/bash $(DOCKER_IMAGE_NAME)
