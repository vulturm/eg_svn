#
# Author: 'Mihai Vultur <xanto@egaming.ro>'
#
# All rights reserved
#

FROM alpine
MAINTAINER Mihai Vultur <xanto@egaming.ro>

ENV SVN_USER=svnuser
ENV SVN_PORT=1022

RUN apk update && \
    apk add subversion openssh openssl && \
    rm /var/cache/apk/*

RUN sed -i '/Subsystem/ s/^#*/#/' /etc/ssh/sshd_config && \
  ssh-keygen -b 4096 -f /etc/ssh/ssh_host_rsa_key -t rsa -N "" ; \
  ssh-keygen -b 1024 -f /etc/ssh/ssh_host_dsa_key -t dsa -N "" ; \
  ssh-keygen -b 521 -f /etc/ssh/ssh_host_ecdsa_key -t ecdsa -N "" ; \
  ssh-keygen -b 4096 -f /etc/ssh/ssh_host_ed25519_key -t ed25519 -N "" ; \
  chmod 600 /etc/ssh/ssh_host_*_key

RUN adduser -D -G svnusers -s /bin/sh ${SVN_USER} && \
  echo "${SVN_USER}:$(openssl rand -base64 32)" | chpasswd && \
  apk del openssl

RUN echo -e "Port $SVN_PORT\n  VersionAddendum OpenBSD\n  Match LocalPort $SVN_PORT\n  AllowUsers ${SVN_USER}\n  AuthenticationMethods publickey\n  X11Forwarding no\n  AllowTcpForwarding no\n  AllowAgentForwarding no\n  PermitTTY no\n  PubkeyAuthentication yes\n  PasswordAuthentication no\n  PermitEmptyPasswords no\n  PermitTunnel no\n  GatewayPorts no\n  Banner \"Authorised use only\"\n  ForceCommand /usr/bin/svnserve -i -r /home/${SVN_USER}/repos --log-file /home/${SVN_USER}/logs/svnserve.log\n" >> /etc/ssh/sshd_config

RUN echo -e "#!/bin/sh\nchown -R ${SVN_USER}:svnusers /home/${SVN_USER}\nchmod +x /home/${SVN_USER}\nchmod 600 /home/${SVN_USER}/.ssh/authorized_keys\n" > /usr/bin/fixpriv
RUN chmod +x /usr/bin/fixpriv

EXPOSE $SVN_PORT

RUN chown -R ${SVN_USER}:svnusers /home/${SVN_USER}
RUN chmod +x /home/${SVN_USER} 

ENTRYPOINT ["/usr/sbin/sshd", "-D", "-E", "/home/svnuser/logs/sshd.log"]
#ENTRYPOINT ["/bin/ping", "8.8.8.8"] 
