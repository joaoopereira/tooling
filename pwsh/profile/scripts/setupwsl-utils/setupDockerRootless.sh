#!/bin/bash

# Rootless setup
sudo apt-get install -y uidmap >/dev/null
dockerd-rootless-setuptool.sh install --skip-iptables &>/dev/null
sudo loginctl enable-linger $USER
echo "export DOCKER_HOST=unix:///run/user/1000/docker.sock" >> ~/.bashrc
sudo setcap cap_net_bind_service=ep $(which rootlesskit)
systemctl --user restart docker
