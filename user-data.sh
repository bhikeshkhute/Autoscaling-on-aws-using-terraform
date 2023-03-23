#!/bin/bash

sudo apt update
sudo apt install apache2 -y 
echo "This is $(hostname -i)" > /var/www/html/index.html
sudo systemctl reload apache2
