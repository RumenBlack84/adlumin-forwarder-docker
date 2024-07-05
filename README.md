# Adlumin-Forwarder-Docker
A repo for the build files needed to create an adlumin log forwarders docker. Please note this is repo does not contain any of adlumins code to avoid any potential copyright issues. You must obtain it from your own log forwarder VM and provide it in a bind mount.

# How to use this docker

## How to get the required tenant ID

Go to your Adlumin portal page https://portal.adlumin.com and move into the context of the tenant that you want your docker to report to. The tenant dropdown is at the very top left of the screen to the right of the Adlumin log. Then on the left hand navigiation bar at the very bottom select "Downloads". In this section at the very top is the "Tenant Data" Section make note of your "Tenant ID" we need this so the logs can be sent to the right tenant to be useable. 

## How to get the adlumin files for our bind volume

While still in the "Downloads" section near the bottom there is a section "Adlumin Forwarder - Syslog Collector VM" either of the supported VM image should work but I prefer the VMware ESXi 6.5+ image as instead of having to boot up a virtual machine or mount a vdisk we can just use 7zip or a similar archive manager to explore the file system and grab what we need.

For the Vmware image we can just extract the zip and then right click the .vmdk file and open it with 7zip there will be two .img files inside 0.img and 1.img. The larger image is the one we want which should be 1.img. 

Regardless of how you manage to access the filesystem we want to pull the folder /usr/local/adlumin and the file /home/adlumin/.bashrc

# Configuration

I recommend keeping unedited copies of these files handy as backups. In my example docker compose below I am placing all the files from /usr/local/adlumin into /appdata/adlumin/forwarder, since some of these files will get edited according to our variables if you are using multiple dockers to serve multiple tenants ensure you are using copies of the originals to another docker volume or bind location so each docker has their own dedicated files. The below docker compose and docker run assume you want to expose all ports for the forwarder but if you'd like you can only expose the ports for the syslog services you want to configure. By only exposing the ports you actually need you can significantly reduce the ported used allowing to run more dockers off just simple bridge networking.

### All variables should not have quotes. Using quotes will cause failures within the docker.

<span style="color: red;">Wrong: Tenant_ID="123"</span>

<span style="color: green;">Correct: Tenant_ID=123</span>

### Variables
- TENANT_ID - This variable is <b>MANDATORY</b> we need it in order to send the logs to the right tenant. Without it the docker will shutdown shortly after starting it as the script will fail.
- SOPHOS_API - This variable is optional, its part of the sophos integration if you need to use it ensure you are putting the API Access URL + Headers block from the integrations instruction as this variable.
- OFFICE365_TOKEN - I'm not even sure this variable is used anymore as the azure integration now covers everything in Azure including Office365, I've included it since it is mentioned in the /usr/local/adlumin/adlumin_config.txt file.
- RUN_EDIT_SCRIPT - The only valid entry for this variable is "yes" with no quotes. This is a required value on the first run of the container. This is using a cut down version of my <a href="https://github.com/RumenBlack84/adlumin310edit">adlumin310edit.sh</a> from my other repo to ensure the code can be properly run in a supported version of python. By default the script requires python 3.6 which has been end of life since October 2021. Once it has been run and the files in the bind mount have been edited this value can be removed if you want to keep the adlumin_forwarder.py script locked the current version. If you want the script to attempt to update everytime the docker starts then keep this value as yes.
- S3_AKEY & S3_SKEY - These values are optional but required to autoupdate the scripts. I recommend setting these if you plan on keeping RUN_EDIT_SCRIPT set to "yes". Both of these values are related. Remeber that .bashrc file we pulled earlier from the log forwarder VM? It holds the AWS keys required to access an S3 bucket that will allow the scripts to update. The updater.py script will call these variables to generate secure URLs and pull down the new scripts using their file keys. Pull the values from the /home/adlumin/.bashrc file and use them with these variables.
# Docker Compose Example
```yml
services:
  adlumin-forwarder:
    image: ghcr.io/rumenblack84/adlumin-forwarder-docker:latest
    environment:
      - TENANT_ID=
      - SOPHOS_API=
      - OFFICE365_TOKEN=
      - RUN_EDIT_SCRIPT=yes
      - S3_AKEY=
      - S3_SKEY=
    ports:
      # Network Security Devices
      - "514:514"
      - "514:514/udp"
      # Firewall
      - "20000:20000"
      - "20000:20000/udp"
      # VPN
      - "20001:20001"
      - "20001:20001/udp"
      # Misc1
      - "20002:20002"
      - "20002:20002/udp"
      # Misc2
      - "20003:20003"
      - "20003:20003/udp"
      # Carbon Black
      - "20005:20005"
      - "20005:20005/udp"
      # Carbon Black Defense
      - "20006:20006"
      - "20006:20006/udp"
      # Dark Trace
      - "20007:20007"
      - "20007:20007/udp"
      # Network Security Devices
      - "30000:30000"
      - "30000:30000/udp"
      # Endpoint Security
      - "30001:30001"
      - "30001:30001/udp"
      # misc3
      - "30002:30002"
      - "30002:30002/udp"
      # misc4
      - "30003:30003"
      - "30003:30003/udp"
      # misc5
      - "30005:30005"
      - "30005:30005/udp"
      # misc6
      - "30006:30006"
      - "30006:30006/udp"
      # misc7
      - "30007:30007"
      - "30007:30007/udp"
      # misc8
      - "30008:30008"
      - "30008:30008/udp"
      # misc9
      - "30009:30009"
      - "30009:30009/udp"
      # misc10
      - "30010:30010"
      - "30010:30010/udp"
      # Sophos
      - "31000:31000"
      - "31000:31000/udp"
      # Crowd Strike
      - "32000:32000"
      - "32000:32000/udp"
      # Hpux
      - "40001:40001"
      - "40001:40001/udp"
      # Aix
      - "40002:40002"
      - "40002:40002/udp"
      # Office365
      - "45000:45000"
      - "45000:45000/udp"
# Uncomment Section 1 of 2 to enable macvlan networking
# This will allow us to assign routable IP address from the hosts network to the container
# This can be very useful due to the amount of ports we are using so that we don't run out 
#    networks:
#      macvlan_net:
#        ipv4_address: 192.168.0.100 # Assign routable IP to container
    volumes:
      - /appdata/adlumin/forwarder:/usr/local/adlumin
# Uncomment Section 2 of 2 to enable macvlan networking 
# This will allow us to assign routable IP address from the hosts network to the container
# This can be very useful due to the amount of ports we are using so that we don't run out 
# networks:
#  macvlan_net:
#    driver: macvlan
#    driver_opts:
#      parent: eth0  # Replace with your host's network interface
#    ipam:
#      config:
#        - subnet: 192.168.0.0/24
#          gateway: 192.168.0.1  # Replace with your network's gateway
#          ip_range: 192.168.0.192/27  # Define a range for your containers
```
# Docker Run Example
This docker run example is just for running a single instance of the forwarder on a host.

### All variables should not have quotes. Using quotes will cause failures within the docker.

<span style="color: red;">Wrong: Tenant_ID="123"</span>

<span style="color: green;">Correct: Tenant_ID=123</span>
```sh
docker run -d \
  --name adlumin-forwarder \  # Name the container
  -e TENANT_ID= \  #Set environment variable TENANT_ID
  -e SOPHOS_API= \  # Set environment variable SOPHOS_API
  -e OFFICE365_TOKEN= \  # Set environment variable OFFICE365_TOKEN
  -e RUN_EDIT_SCRIPT=yes \  # Set environment variable RUN_EDIT_SCRIPT
  -e S3_AKEY= \  # Set environment variable S3_AKEY
  -e S3_SKEY= \  # Set environment variable S3_SKEY
  -p 514:514 \  # Network Security Devices (TCP)
  -p 514:514/udp \  # Network Security Devices (UDP)
  -p 20000:20000 \  # Firewall (TCP)
  -p 20000:20000/udp \  # Firewall (UDP)
  -p 20001:20001 \  # VPN (TCP)
  -p 20001:20001/udp \  # VPN (UDP)
  -p 20002:20002 \  # Misc1 (TCP)
  -p 20002:20002/udp \  # Misc1 (UDP)
  -p 20003:20003 \  # Misc2 (TCP)
  -p 20003:20003/udp \  # Misc2 (UDP)
  -p 20005:20005 \  # Carbon Black (TCP)
  -p 20005:20005/udp \  # Carbon Black (UDP)
  -p 20006:20006 \  # Carbon Black Defense (TCP)
  -p 20006:20006/udp \  # Carbon Black Defense (UDP)
  -p 20007:20007 \  # Dark Trace (TCP)
  -p 20007:20007/udp \  # Dark Trace (UDP)
  -p 30000:30000 \  # Network Security Device (TCP)
  -p 30000:30000/udp \  # Network Security Device (UDP)
  -p 30001:30001 \  # Endpoint Security (TCP)
  -p 30001:30001/udp \  # Endpoint Security (UDP)
  -p 30002:30002 \  # misc3 (TCP)
  -p 30002:30002/udp \  # misc3 (UDP)
  -p 30003:30003 \  # misc4 (TCP)
  -p 30003:30003/udp \  # misc4 (UDP)
  -p 30005:30005 \  # misc5 (TCP)
  -p 30005:30005/udp \  # misc5 (UDP)
  -p 30006:30006 \  # misc6 (TCP)
  -p 30006:30006/udp \  # misc6 (UDP)
  -p 30007:30007 \  # misc7 (TCP)
  -p 30007:30007/udp \  # misc7 (UDP)
  -p 30008:30008 \  # misc8 (TCP)
  -p 30008:30008/udp \  # misc8 (UDP)
  -p 30009:30009 \  # misc9 (TCP)
  -p 30009:30009/udp \  # misc9 (UDP)
  -p 30010:30010 \  # misc10 (TCP)
  -p 30010:30010/udp \  # misc10 (UDP)
  -p 31000:31000 \  # Sophos (TCP)
  -p 31000:31000/udp \  # Sophos (UDP)
  -p 32000:32000 \  # Crowd Strike (TCP)
  -p 32000:32000/udp \  # Crowd Strike (UDP)
  -p 40001:40001 \  # Hpux (TCP)
  -p 40001:40001/udp \  # Hpux (UDP)
  -p 40002:40002 \  # Aix (TCP)
  -p 40002:40002/udp \  # Aix (UDP)
  -p 45000:45000 \  # Office365 (TCP)
  -p 45000:45000/udp \  # Office365 (UDP)
  -v /appdata/adlumin/forwarder:/usr/local/adlumin \  # Mount volume
  ghcr.io/rumenblack84/adlumin-forwarder-docker:latest  # Image name
```
# List of ports and what they forward for reference

``` python
# Network Security Devices
TCP/UDP 514
# Firewall
TCP/UDP 20000
# VPN
TCP/UDP 20001
# Misc1
TCP/UDP 20002
# Misc2
TCP/UDP 20003
# Carbon Black
TCP/UDP 20005
# Carbon Black Defense
TCP/UDP 20006
# Dark Trace
TCP/UDP 20007
# Network Security Device
TCP/UDP 30000
# Endpoint Security
TCP/UDP 30001
# misc3
TCP/UDP 30002
# misc4
TCP/UDP 30003
# misc5
TCP/UDP 30005
# misc6
TCP/UDP 30006
# misc7
TCP/UDP 30007
# misc8
TCP/UDP 30008
# misc9
TCP/UDP 30009
# misc10
TCP/UDP 30010
# Sophos
TCP/UDP 31000
# Crowd Strike
TCP/UDP 32000
# Hpux
TCP/UDP 40001
# Aix
TCP/UDP 40002
# Office365
TCP/UDP 45000
```