FROM alpine:3.21 AS base

##
## Base builder image
##
FROM base AS builder

RUN apk --update add --virtual .build-deps build-base automake autoconf libtool git linux-pam-dev zlib-dev openssl-dev wget

##
## Duo builder image
##
FROM builder AS duo-builder

ARG DUO_VERSION=2.0.4
RUN wget https://dl.duosecurity.com/duo_unix-${DUO_VERSION}.tar.gz && \
    mkdir -p src && \
    tar -zxf duo_unix-${DUO_VERSION}.tar.gz --strip-components=1 -C src

RUN cd src && \
    ./configure \
        --with-pam=/dist/lib64/security \
        --prefix=/dist/usr && \
    make && \
    make install

##
## Google Authenticator PAM module builder image
##
FROM builder AS google-authenticator-libpam-builder

ARG AUTHENTICATOR_LIBPAM_VERSION=1.11
RUN git clone --branch ${AUTHENTICATOR_LIBPAM_VERSION} --single-branch https://github.com/google/google-authenticator-libpam src

RUN cd src && \
    ./bootstrap.sh && \
    ./configure \
        --prefix=/usr && \
    make && \
    make install

##
## OpenSSH Portable builder image
##
FROM builder AS openssh-portable-builder

ARG OPENSSH_VERSION=V_9_9_P2
RUN git clone --branch ${OPENSSH_VERSION} --single-branch https://github.com/openssh/openssh-portable src

COPY patches/ /patches/

RUN cd src && \
    find ../patches/openssh/** -type f -exec patch -p1 -i {} \; && \
    autoreconf && \
    ./configure \
        --prefix=/dist/usr \
        --sysconfdir=/etc/ssh \
        --datadir=/dist/usr/share/openssh \
        --libexecdir=/usr/lib/ssh \
        --mandir=/dist/usr/share/man \
        --with-pid-dir=/run \
        --with-mantype=man \
        --with-privsep-path=/var/empty \
        --with-privsep-user=sshd \
        --with-ssl-engine \
        --disable-wtmp \
        --with-pam=/usr/lib64/security && \
    make && \
    make install

##
## Bastion image
##
FROM base

LABEL maintainer="erik@cloudposse.com"

USER root

## Install dependencies
RUN apk --update add curl drill groff util-linux bash xauth gettext openssl-dev shadow linux-pam libqrencode sudo && \
    rm -rf /etc/ssh/ssh_host_*_key* && \
    rm -f /usr/bin/ssh-agent && \
    rm -f /usr/bin/ssh-keyscan && \
    touch /var/log/lastlog && \
    mkdir -p /var/run/sshd && \
    ln -s /etc/profile.d/color_prompt.sh.disabled /etc/profile.d/color_prompt.sh

## Install sudosh
ENV SUDOSH_VERSION=0.3.0
RUN wget https://github.com/cloudposse/sudosh/releases/download/${SUDOSH_VERSION}/sudosh_linux_386 -O /usr/bin/sudosh && \
    chmod 755 /usr/bin/sudosh

## Install Duo
COPY --from=duo-builder dist/ /

## Install Google Authenticator PAM module
COPY --from=google-authenticator-libpam-builder /usr /usr

## Install OpenSSH Portable
COPY --from=openssh-portable-builder dist/ /
COPY --from=openssh-portable-builder /usr/lib/ssh /usr/lib/ssh


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

## Tolerate 5 consecutive failures
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
