#!/bin/bash

sleep 30

# Install docker
sudo apt-get update
sudo apt-get install -y cloud-utils apt-transport-https ca-certificates curl software-properties-common
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update
sudo apt-get install -y docker-ce
sudo usermod -aG docker ubuntu

# Install docker-compose
sudo curl -L https://github.com/docker/compose/releases/download/1.21.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

#Docker-compose up wordpress

sudo mkdir -p /wordpress/nginx-conf

sudo cp /home/ubuntu/docker-compose.yml /wordpress/docker-compose.yml
sudo cp /home/ubuntu/nginx.conf /wordpress/nginx-conf/nginx.conf

cd /wordpress
sudo docker-compose up -d