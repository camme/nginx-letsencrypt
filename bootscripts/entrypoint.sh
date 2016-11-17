#!/bin/bash

cp "/nginx-templates/${NGINX_SITE_TEMPLATE}.conf" /etc/nginx/conf.d/site.conf
sed -i "s/\$SITE_HOST/$SITE_HOST/g" /etc/nginx/conf.d/site.conf

service nginx start  

/opt/certbot/certbot-auto certonly --webroot -w /var/www -d $SITE_HOST --noninteractive --agree-tos --email $CERT_EMAIL

cp "/nginx-templates/${NGINX_SITE_TEMPLATE}.https.conf" /etc/nginx/conf.d/site.conf
sed -i "s/\$SITE_HOST/$SITE_HOST/g" /etc/nginx/conf.d/site.conf

echo 'Done';
