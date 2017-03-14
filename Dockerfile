FROM alpine:edge
MAINTAINER Erik Osterman "erik@cloudposse.com"

USER root

ARG OPENSSH_VERSION=V_7_4_P1

RUN apk --update add linux-pam libssl1.0 shadow ca-certificates openssl && \
    update-ca-certificates && \
    ln -s /lib /lib64

ADD patches/ /usr/src/patches/

# Building OpenSSH on alpine: http://git.alpinelinux.org/cgit/aports/tree/main/openssh/APKBUILD 

RUN apk --update add --virtual .build-deps build-base automake autoconf libtool git linux-pam-dev openssl-dev wget && \
    mkdir -p /usr/src && \
    cd /usr/src && \
    ( wget https://dl.duosecurity.com/duo_unix-latest.tar.gz && \
      tar zxf duo_unix-latest.tar.gz && \
      cd duo_unix-* && \
      ./configure --with-pam --prefix=/usr && \
      make && \
      make install && \ 
      cd .. && \
      rm -rf duo_unix-* && \
      rm -f duo_unix-latest.tar.gz \
    ) && \
    ( git clone https://github.com/google/google-authenticator-libpam /usr/src/google-authenticator-libpam && \
      cd /usr/src/google-authenticator-libpam && \
      ./bootstrap.sh && \
      ./configure --prefix=/ && \
      make && \
      make install) && \
    ( git clone https://github.com/openssh/openssh-portable.git /usr/src/openssh && \
      cd /usr/src/openssh && \
      git checkout ${OPENSSH_VERSION} && \
      find ../patches/openssh -type f -exec patch -p1 -i {} \; && \
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
      make && \
      make install) && \
    rm -rf /usr/src && \
    apk del .build-deps && \
    rm -rf /var/cache/apk/*

RUN apk --update add curl drill groff util-linux bash xauth gettext sudo && \
  rm -rf /etc/ssh/ssh_host_*_key* && \
  rm -f /usr/bin/ssh-agent && \
  rm -f /usr/bin/ssh-keyscan && \
  touch /var/log/lastlog && \
  mkdir -p /var/run/sshd && \
  mv /etc/profile.d/color_prompt /etc/profile.d/color_prompt.sh

ENV SUDOSH_VERSION=0.1.3
ADD https://github.com/cloudposse/sudosh/releases/download/${SUDOSH_VERSION}/sudosh_linux_386 /usr/bin/sudosh
RUN chmod 755 /usr/bin/sudosh

# System ENV
ENV TIMEZONE=Etc/UTC
ENV TERM=xterm
ENV HOSTNAME=bastion

ENV MFA_PROVIDER=duo

ENV UMASK=0022

ENV DUO_IKEY=
ENV DUO_SKEY=
ENV DUO_HOST=
ENV DUO_FAILMODE=secure
ENV DUO_AUTOPUSH=yes
ENV DUO_PROMPTS=1

ENV ENFORCER_ENABLED=true
ENV ENFORCER_ACLS_ENABLED=true
ENV ENFORCER_ACLS_PERMIT_SCP=true
ENV ENFORCER_CLEAN_HOME_ENABLED=true

ENV SSH_AUDIT_ENABLED=true

# Enable Rate Limiting
ENV RATE_LIMIT_ENABLED=true

# Tolerate 5 consecutive fairues    
ENV RATE_LIMIT_MAX_FAILURES=5

# Lock accounts out for 300 seconds (5 minutes) after repeated failures
ENV RATE_LIMIT_LOCKOUT_TIME=300
# Sleep N microseconds between failed attempts
ENV RATE_LIMIT_FAIL_DELAY=3000000

#
# Slack
#
ENV SLACK_ENABLED=false
ENV SLACK_HOOK=sshrc
ENV SLACK_WEBHOOK_URL=
ENV SLACK_USERNAME=ssh-bot
ENV SLACK_TIMEOUT=2
ENV SLACK_FATAL_ERRORS=true

#
# SSH
#
ENV SSH_AUTHORIZED_KEYS_COMMAND=none
ENV SSH_AUTHORIZED_KEYS_COMMAND_USER=nobody

ADD rootfs/ /

EXPOSE 22

ENTRYPOINT ["/init"]
