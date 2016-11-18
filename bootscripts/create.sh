#!/bin/bash

set -e

mkdir -p /nginx-letsencrypt-temp
mkdir -p /etc/nginx/sites-enabled

ORIGINAL_FILE=$1
#../examples/test-size.conf

WORK_FILE=/nginx-letsencrypt-temp/test-size.conf

cp $ORIGINAL_FILE $WORK_FILE

TEMPLATE_ROOT=/nginx-templates


CONTENT=$(cat $WORK_FILE | grep server_name)

re='.*server_name(.*);'
[[ $CONTENT =~ $re ]]
HOSTS=${BASH_REMATCH[1]}

HOSTS=$(echo $HOSTS | xargs)



#echo "hosts: $HOSTS"

#sed '/server/ r ../templates/well-known.part' test-size.conf

sed -i.bak '/server {/ {
r /nginx-templates/well-known.part
}' $WORK_FILE

cp $WORK_FILE /etc/nginx/sites-enabled

cat $WORK_FILE

service nginx restart

# ------------------- start certbot and get cert -------------------
/opt/certbot/certbot-auto certonly --webroot -w /var/www -d $HOSTS --noninteractive --agree-tos --email $CERT_EMAIL

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

rm $WORK_FILE.bak
rm $WORK_FILE

service nginx restart

echo 'Done';

