#!/bin/bash

cp "/nginx-templates/$NGINX_SITE_TEMPLATE" /etc/nginx/conf.d/site.conf
service nginx start  

/opt/certbot/certbot-auto certonly --webroot -w /var/www -d $SITE_HOST --noninteractive --agree-tos --email $CERT_EMAIL

echo 'yes';
