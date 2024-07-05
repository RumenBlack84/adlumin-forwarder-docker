# syntax=docker/dockerfile:1

FROM python:3.10.14-alpine3.20

RUN \
  echo "**** install packages ****" && \
  apk add --no-cache \
    git \
    build-base \
    zstd-dev \
    bash \
    shadow && \
  echo "**** Installing required python dependencies ****" && \
  python -m pip install --upgrade pip && \
  pip install requests urllib3 zstandard boto3 && \
  mkdir -p /usr/local/adlumin && \
  chsh -s /bin/bash root

# Copy the local repository into the image
COPY adlumin310edit.sh /usr/local/bin/adlumin310edit.sh
RUN chmod +x /usr/local/bin/adlumin310edit.sh

# Copy the startup script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Declaring a volume so we can point to extracted adlumin code from the log forwarder VM
VOLUME /usr/local/adlumin

# Set working directory to the adlumin files
WORKDIR /usr/local/adlumin

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# ports and volumes
# TCP Ports
# Network Security Devices
EXPOSE 514
# Firewall
EXPOSE 20000
# VPN
EXPOSE 20001
# Misc1
EXPOSE 20002
# Misc2
EXPOSE 20003
# Carbon Black
EXPOSE 20005
# Carbon Black Defense
EXPOSE 20006
# Dark Trace
EXPOSE 20007
# Network Security Device
EXPOSE 30000
# Endpoint Security
EXPOSE 30001
# misc3
EXPOSE 30002
# misc4
EXPOSE 30003
# misc5
EXPOSE 30005
# misc6
EXPOSE 30006
# misc7
EXPOSE 30007
# misc8
EXPOSE 30008
# misc9
EXPOSE 30009
# misc10
EXPOSE 30010
# Sophos
EXPOSE 31000
# Crowd Strike
EXPOSE 32000
# Hpux
EXPOSE 40001
# Aix
EXPOSE 40002
# Office365
EXPOSE 45000

# UDP Ports
# Network Security Devices
EXPOSE 514/udp
# Firewall
EXPOSE 20000/udp
# VPN
EXPOSE 20001/udp
# Misc1
EXPOSE 20002/udp
# Misc2
EXPOSE 20003/udp
# Carbon Black
EXPOSE 20005/udp
# Carbon Black Defense
EXPOSE 20006/udp
# Dark Trace
EXPOSE 20007/udp
# Network Security Device
EXPOSE 30000/udp
# Endpoint Security
EXPOSE 30001/udp
# misc3
EXPOSE 30002/udp
# misc4
EXPOSE 30003/udp
# misc5
EXPOSE 30005/udp
# misc6
EXPOSE 30006/udp
# misc7
EXPOSE 30007/udp
# misc8
EXPOSE 30008/udp
# misc9
EXPOSE 30009/udp
# misc10
EXPOSE 30010/udp
# Sophos
EXPOSE 31000/udp
# Crowd Strike
EXPOSE 32000/udp
# Hpux
EXPOSE 40001/udp
# Aix
EXPOSE 40002/udp
# Office365
EXPOSE 45000/udp

# dont think I need any volumes since we dont really care about any user data beyond tenantid which I can pass in a variable
#VOLUME /usr/local/adlumin
