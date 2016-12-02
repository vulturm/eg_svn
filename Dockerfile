FROM alpine
MAINTAINER Mihai Vultur

ENV SVN_USER=svnuser
ENV SVN_PORT=1022

RUN apk update && \
    apk add subversion openssh openssl && \
    apk add bash && \
    rm /var/cache/apk/*

RUN sed -i '/Subsystem/ s/^#*/#/' /etc/ssh/sshd_config && \
  ssh-keygen -b 4096 -f /etc/ssh/ssh_host_rsa_key -t rsa -N "" ; \
  ssh-keygen -b 1024 -f /etc/ssh/ssh_host_dsa_key -t dsa -N "" ; \
  ssh-keygen -b 521 -f /etc/ssh/ssh_host_ecdsa_key -t ecdsa -N "" ; \
  ssh-keygen -b 4096 -f /etc/ssh/ssh_host_ed25519_key -t ed25519 -N "" ; \
  chmod 600 /etc/ssh/ssh_host_*_key

RUN adduser -D -G svnusers -s /bin/bash ${SVN_USER} && \
  echo "${SVN_USER}:$(openssl rand -base64 32)" | chpasswd && \
  apk del openssl


RUN echo -e "Port $SVN_PORT\n  VersionAddendum OpenBSD\n  Match LocalPort $SVN_PORT\n  AllowUsers ${SVN_USER}\n  AuthenticationMethods publickey\n  X11Forwarding no\n  AllowTcpForwarding no\n  AllowAgentForwarding no\n  PermitTTY no\n  PubkeyAuthentication yes\n  PasswordAuthentication no\n  PermitEmptyPasswords no\n  PermitTunnel no\n  GatewayPorts no\n  Banner \"Authorised use only\"\n  ForceCommand /usr/bin/svnserve -i -r /home/${SVN_USER}/repos --log-file /home/${SVN_USER}/logs/svn.log\n" >> /etc/ssh/sshd_config

EXPOSE $SVN_PORT
VOLUME /home/${SVN_USER}/repos

RUN mkdir -p /home/${SVN_USER}/logs /home/${SVN_USER}/.ssh

RUN echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDZ6gFraNQ2lpaJ0NJTIxR4kdSJ6MkO6PjtWXIX9+Tvv9R44Md7EMeTrnwKXHuwhOcYiFyEfcFC6zd1zL0EllHZgTrDosEM9tkylqBlZtgndlT8y+gp2XmgG0siVHIyxyQyNR71F5xtqAFojgYhhs7aar50nZYPK0nPGS2Wum2GkW9I/35VdvLyiKhwwqhArnO/ghde+FSh/A3HKcADWZDDyAFUgKqDDARKFR81w67NqYEWJUK7ON1t6HgP1xzeevykVQvURkpcL7h9VpCqUB6v8lzgmmJneRYUVJnMvB17P1XHKjmnqvbSA/8exTH0iOWIs52QjR0yCydX0LnmTm/r samp@srvn.egaming.ro' >> /home/${SVN_USER}/.ssh/authorized_keys
RUN echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDn0yvgQXKzVYauve+nOLAImeYJYBUWEqldz/h+8xH4lNEECu6oM4l55ZilS1WB4PQD6H8fTal/zW8MIaX71UwDEby2haqnfEZ2oC1AmBXvMH+n3TExjOXLVJ910msc5TxRqsfCiuV4lLPrFe7N1EF9EIS4uk42YduNHPysbFP7VVy7HmeUGHoeonpumRgfiXfsmRFDz7JVubMpXYeXmxM7u3V8Brc6VllXFiBIUqxy+PxVLrEImPua/bC1kLz6C7hyjH2SSNsilGatWONq/d0BpZF6cxjQP1tI4nRbs4YdWk3KhSz1gauzPKS60ZR4YldJmI7Gleb0d/Xxwv3M21Qx root@xantos-hdd' >> /home/${SVN_USER}/.ssh/authorized_keys
RUN echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDQR/UxNXnD6gSxhJwejZE0YjBYPHtSRQJp2fU0JjOSTHye6apdQme/XPGl8atAng6fyzlZcEaZFMDq7cNFZhrZzgCwtCaRRVdZh+wwJmTa0Qzi/sWK73+nGYnePfN1cFZdY9sLi9UnBgVmB5X5kgnCx4SIGZqUcze+fGW4LaGMVfcwZUo51TP8JfjRtfwAhXl2kIkTR1iY4pJ+ryTzdD5iLSwen5RbJbHsQ1GVpCp3nuUQn7z8Bsqt/BJClKM7HcOV1IbzPKIs49Z2ZP/+n03Km4VKaVkqPU8m29PBk8pYK6QP18SNTvgRFugqGSJqNDQt0H8FM1uGc8tqAuttlbxN xanto@fedora.test.lo' >> /home/${SVN_USER}/.ssh/authorized_keys


RUN chown -R ${SVN_USER}:svnusers /home/${SVN_USER}
RUN chmod +x /home/${SVN_USER} 
RUN chmod 600 /home/${SVN_USER}/.ssh/authorized_keys

#ENTRYPOINT [ "/usr/sbin/sshd", "-D" ]
ENTRYPOINT ["/bin/ping", "8.8.8.8"] 
