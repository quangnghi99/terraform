#!/bin/bash
yum update -y
yum install -y httpd.x86_64
systemctl start httpd.service
systemctl enable httpd.service
echo “Hello World from Nghi Nguyen” > /var/www/html/index.html
echo <h1> Nghi Nguyen </h1> > /var/www/html/index.html