#!/bin/bash
sudo yum update -y &&
sudo yum install -y nginx
echo "Hello World" > /var/www/html/index.html