#!/bin/bash

set -e

echo "Cert doesnt exists, creating"
service nginx start

mkdir -p /etc/nginx/sites-enabled

ORIGINAL_FILE=$1

WORK_FILE=/nginx-letsencrypt-temp/nginx-temp-conf.conf

echo "Copying the original nginx site config"
cp $ORIGINAL_FILE $WORK_FILE

TEMPLATE_ROOT=/nginx-templates


CONTENT=$(cat $WORK_FILE | grep server_name)

re='.*server_name(.*);'
[[ $CONTENT =~ $re ]]
HOSTS=${BASH_REMATCH[1]}

HOSTS=$(echo $HOSTS | xargs)

echo "Parsing its content and adding well-known statement"

#echo "hosts: $HOSTS"

sed -i.bak '/server {/ {
r /nginx-templates/well-known.part
}' $WORK_FILE

echo "Copying to nginx sites-enabled folder"

cp $WORK_FILE /etc/nginx/sites-enabled

echo "Restarting nginx"

service nginx restart

# ------------------- start certbot and get cert -------------------
if [ -z "$DRY_RUN" ]; then
    /opt/certbot/certbot-auto certonly --webroot -w /var/www -d $HOSTS --noninteractive --agree-tos --email $CERT_EMAIL
else 
    echo "Dry run!"
    /opt/certbot/certbot-auto certonly --dry-run --webroot -w /var/www -d $HOSTS --noninteractive --agree-tos --email $CERT_EMAIL
fi  


# REDO
echo "Begin to process nginx site config again, now for ssl"
cp $ORIGINAL_FILE $WORK_FILE

sed -i.bak '/listen/d' $WORK_FILE

sed -i.bak '/server {/ {
r /nginx-templates/https.part
}' $WORK_FILE

sed -i.bak "s/\$HOST_NAME/$HOSTS/g" $WORK_FILE

sed -i.bak '/server {/ {
r /nginx-templates/redirect.part
N
}' $WORK_FILE

sed -i.bak "s/\$HOST_NAME/$HOSTS/g" $WORK_FILE

cat $WORK_FILE

echo "Copy conf to sites-enabled"
cp $WORK_FILE /etc/nginx/sites-enabled

rm $WORK_FILE.bak
rm $WORK_FILE

echo "Restarting nginx again"
service nginx restart

service nginx stop

echo 'Done';

