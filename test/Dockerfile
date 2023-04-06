FROM alpine:3.17

RUN apk add \
	openssh-client \
	sshpass

COPY ./client_test.sh /
RUN chmod 755 /client_test.sh

CMD ./client_test.sh
