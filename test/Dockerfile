FROM alpine:3.17

RUN apk add \
	openssh-client \
	sshpass

COPY ./test_client.sh /
RUN chmod 755 /test_client.sh

CMD ./test_client.sh
