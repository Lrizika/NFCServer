#!/bin/bash

CONFIG_BUCKET="nebulous-config-files"
MODS_BUCKET="nebulous-map-mods"

echo "Starting CloudWatch setup"
add-apt-repository multiverse -y
apt update
apt install awscli -y

wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb -O /home/ubuntu/amazon-cloudwatch-agent.deb
dpkg -i -E /home/ubuntu/amazon-cloudwatch-agent.deb

aws s3 cp s3://$CONFIG_BUCKET/cloudwatch-config.json /home/ubuntu/cloudwatch-config.json
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/home/ubuntu/cloudwatch-config.json


echo "Adding steam user"
useradd -m steam
passwd -d steam


echo "Setting up required directories"
mkdir /home/steam/.steam
chown steam:steam /home/steam/.steam
mkdir /home/steam/.steam/sdk64
chown steam:steam /home/steam/.steam/sdk64
mkdir /home/steam/SteamSDK
chown steam:steam /home/steam/SteamSDK
mkdir /home/steam/NFCServer
chown steam:steam /home/steam/NFCServer
mkdir /home/steam/NFCServer/Config
chown steam:steam /home/steam/NFCServer/Config
mkdir /var/log/nfc-server
chown steam:steam /var/log/nfc-server


echo "Installing SteamCMD"
apt install software-properties-common -y
dpkg --add-architecture i386
apt update
apt install lib32gcc-s1 -y

echo steam steam/question select "I AGREE" | debconf-set-selections
echo steam steam/license note '' | debconf-set-selections
DEBIAN_FRONTEND=noninteractive apt-get install steamcmd -y


echo "Running steam user commands"
su steam <<STEAM_CMDS
/usr/games/steamcmd +force_install_dir /home/steam/NFCServer +login anonymous +app_update 2353090 validate +quit
/usr/games/steamcmd +force_install_dir /home/steam/SteamSDK +login anonymous +app_update 1007 validate +quit
ln -s /home/steam/SteamSDK/linux64/steamclient.so /home/steam/.steam/sdk64/steamclient.so
mkdir /home/steam/NFCServer/steamapps/workshop/content/887570/
aws s3 sync s3://$MODS_BUCKET /home/steam/NFCServer/steamapps/workshop/content/887570/
aws s3 cp s3://$CONFIG_BUCKET/appworkshop_887570.acf /home/steam/NFCServer/steamapps/workshop/appworkshop_887570.acf
chmod 766 /home/steam/NFCServer/steamapps/workshop/appworkshop_887570.acf
aws s3 cp s3://$CONFIG_BUCKET/config.xml /home/steam/NFCServer/Config/config.xml
STEAM_CMDS


echo "Configuring nfc-server service"
aws s3 cp s3://$CONFIG_BUCKET/nfc-server.service /etc/systemd/system/nfc-server.service

systemctl daemon-reload
systemctl enable --now nfc-server




