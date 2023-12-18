#!/bin/bash

sudo apt-get update -qq >/dev/null
DEBIAN_FRONTEND=noninteractive sudo apt-get install -y -qq apt-transport-https ca-certificates curl >/dev/null
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL "https://download.docker.com/linux/ubuntu/gpg" | sudo gpg --dearmor --yes -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu jammy stable" > /etc/apt/sources.list.d/docker.list
sudo apt-get update -qq >/dev/null
DEBIAN_FRONTEND=noninteractive sudo apt-get install -y -qq docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-ce-rootless-extras docker-buildx-plugin >/dev/null

# Add your user to the Docker group
sudo usermod -aG docker $USER

# Using Ubuntu 22.04 or Debian 10+? You need to do 1 extra step for iptables
# compatibility, you'll want to choose option (1) to use iptables-legacy from
# the prompt that'll come up when running the command below.
#
# You'll likely need to reboot Windows or at least restart WSL after applying
# this, otherwise networking inside of your containers won't work.
sudo update-alternatives --set iptables /usr/sbin/iptables-legacy >/dev/null

# Expose tcp socket
sudo sed -i '/^ExecStart=.*dockerd/s/$/ -H tcp:\/\/0.0.0.0:2375/' /lib/systemd/system/docker.service
sudo systemctl daemon-reload
sudo systemctl restart docker.service
docker swarm init