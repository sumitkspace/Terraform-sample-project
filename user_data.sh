#!/bin/bash
sudo yum update -y
sudo yum install -y nginx
sudo systemctl start nginx
sudo yum install -y httpd
sudo systemctl start httpd
sudo yum install -y git
sudo echo "Welcome to Terraform Nginx Server" > /var/www/html/index.html
