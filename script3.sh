#!/bin/sh

systemctl disable systemd-resolved
systemctl stop systemd-resolved

echo nameserver 8.8.8.8 > /etc/resolv.conf

apt update
apt -y install ntpdate

ntpdate time.nist.gov

curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

sudo curl -L "https://github.com/docker/compose/releases/download/v2.14.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

curl https://raw.githubusercontent.com/pz0f/vpn/main/config3.tar | tar xv

./run.sh