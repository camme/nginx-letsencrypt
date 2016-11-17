cp "/nginx-templates/$NGINX_SITE_TEMPLATE" /etc/nginx/conf.d/site.conf
sudo service nginx start  
echo 'yes';
