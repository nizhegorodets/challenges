#!/bin/bash
sudo apt-get update -y -qq
sudo apt-get install python3-pip -y -qq
sudo pip install boto3
sudo pip install ec2-metadata
chmod +x /tmp/ec2manager.py
sudo mv /tmp/p.service /etc/systemd/system/p.service
sudo apt-get install apache2 -y -qq
sudo service apache2 start
sudo systemctl enable p.service
sudo systemctl start p.service