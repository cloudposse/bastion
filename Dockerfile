##
## Base builder image
##
FROM alpine:3.8 as builder

RUN apk --update add --virtual .build-deps build-base automake autoconf libtool git linux-pam-dev openssl-dev wget


##
## Duo builder image
##
FROM builder as duo-builder

ARG DUO_VERSION=1.10.5
RUN wget https://dl.duosecurity.com/duo_unix-${DUO_VERSION}.tar.gz && \
    mkdir -p dist && \
    tar -zxf duo_unix-${DUO_VERSION}.tar.gz --strip-components=1 -C dist

RUN cd dist && \
    ./configure --with-pam --prefix=/usr && \
    make


##
## Google Authenticator PAM module builder image
##
FROM builder as google-authenticator-libpam-builder

ARG AUTHENTICATOR_LIBPAM_VERSION=1.05
RUN git clone --branch ${AUTHENTICATOR_LIBPAM_VERSION} --single-branch https://github.com/google/google-authenticator-libpam dist

RUN cd dist && \
    ./bootstrap.sh && \
    ./configure --prefix=/ && \
    make


##
## OpenSSH Portable builder image
##
FROM builder as openssh-portable-builder

ARG OPENSSH_VERSION=V_7_8_P1
RUN git clone --branch ${OPENSSH_VERSION} --single-branch https://github.com/openssh/openssh-portable dist

COPY patches/ /patches/

RUN cd dist && \
    find ../patches/openssh/** -type f -exec patch -p1 -i {} \; && \
    autoreconf && \
    ./configure \
        --prefix=/usr \
        --sysconfdir=/etc/ssh \
        --datadir=/usr/share/openssh \
        --libexecdir=/usr/lib/ssh \
        --mandir=/usr/share/man \
        --with-pid-dir=/run \
        --with-mantype=man \
        --with-privsep-path=/var/empty \
        --with-privsep-user=sshd \
        --with-md5-passwords \
        --with-ssl-engine \
        --disable-wtmp \
        --with-pam && \
    make


##
## Bastion image
##
FROM builder

LABEL maintainer="erik@cloudposse.com"

USER root

RUN apk add shadow sudo curl

## Install sudosh
ENV SUDOSH_VERSION=0.1.3
RUN wget https://github.com/cloudposse/sudosh/releases/download/${SUDOSH_VERSION}/sudosh_linux_386 -O /usr/bin/sudosh && \
    chmod 755 /usr/bin/sudosh

## Install Duo
COPY --from=duo-builder dist dist
RUN make --directory=dist install && \
    rm -rf dist

## Install Google Authenticator PAM module
COPY --from=google-authenticator-libpam-builder dist dist
RUN make --directory=dist install && \
    rm -rf dist

## Install OpenSSH Portable
COPY --from=openssh-portable-builder dist dist
RUN make --directory=dist install && \
    rm -rf dist

## System
ENV TIMEZONE="Etc/UTC" \
    TERM="xterm" \
    HOSTNAME="bastion"

ENV MFA_PROVIDER="duo"

ENV UMASK="0022"

## Duo
ENV DUO_IKEY="" \
    DUO_SKEY="" \
    DUO_HOST="" \
    DUO_FAILMODE="secure" \
    DUO_AUTOPUSH="yes" \
    DUO_PROMPTS="1"

## Enforcer
ENV ENFORCER_ENABLED="true" \
    ENFORCER_CLEAN_HOME_ENABLED="true"


## Enable Rate Limiting
ENV RATE_LIMIT_ENABLED="true"

## Tolerate 5 consecutive fairues    
ENV RATE_LIMIT_MAX_FAILURES="5"
## Lock accounts out for 300 seconds (5 minutes) after repeated failures
ENV RATE_LIMIT_LOCKOUT_TIME="300"
## Sleep N microseconds between failed attempts
ENV RATE_LIMIT_FAIL_DELAY="3000000"

## Slack
ENV SLACK_ENABLED="false" \
    SLACK_HOOK="sshrc" \
    SLACK_WEBHOOK_URL="" \
    SLACK_USERNAME="" \
    SLACK_TIMEOUT="2" \
    SLACK_FATAL_ERRORS="true"

## SSH
ENV SSH_AUDIT_ENABLED="true" \
    SSH_AUTHORIZED_KEYS_COMMAND="none" \
    SSH_AUTHORIZED_KEYS_COMMAND_USER="nobody"

ADD rootfs/ /

EXPOSE 22
ENTRYPOINT ["/init"]
