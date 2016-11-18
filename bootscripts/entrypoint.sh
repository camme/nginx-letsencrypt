#!/bin/bash

set -e


service nginx start
#openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048  
[ -f /etc/ssl/certs/dhparam.pem ] && echo "Diffie-Helman group already created" || openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048

SITE_CONF_FILE=$(ls -d -1 /nginx-letsencrypt/**)
./create.sh $SITE_CONF_FILE

nginx

