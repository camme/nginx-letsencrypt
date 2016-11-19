#!/bin/bash

set -e

# Check if we have created the Diffie-Helman group. If not, create it.
[ -f /etc/ssl/certs/dhparam.pem ] && echo "Diffie-Helman group already created" || openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048

if [ "$PROXY_PASS" = "true" ]; then

    # Convert the PROXY_DOMAINS to an array, if it isnt already
	if [[ "$(declare -p $PROXY_DOMAINS)" =~ "declare -a" ]]; then
		echo "Found array of proxies"
	else
		echo "Found single proxy"
		PROXY_DOMAINS[0]=$PROXY_DOMAINS
	fi

    # Iterate trough the list of domains
	for PROXY_INFO in "${PROXY_DOMAINS[@]}"
    do

        # Pick out the host and the proxy address
        IFS='|' read -r PROXY_DOMAIN PROXY_ADDRESS <<< "$PROXY_INFO"

		echo "Found proxy pass statement ($PROXY_INFO): Proxy $PROXY_DOMAIN to $PROXY_ADDRESS"

        # If the hosts have spaces, it means is a list of domains
        # but we cant use that for our conf file so we replace any spaces with dashes to create
        # a nginx site conf file
        if [[ "$string" =~ \ |\' ]]; then
            SLUG=${${PROXY_DOMAIN}//[[:blank:]]/-}
        else
            SLUG=$PROXY_DOMAIN
        fi

        # Set the conf file name
		SITE_CONF_FILE=/nginx-letsencrypt-temp/${SLUG}.conf

        # Copy the file to our temp folder
		cp /nginx-templates/proxy-pass.conf $SITE_CONF_FILE

        # Replace the hosts in the conf file and replace the proxy addres
		sed -i.bak 's@{PROXY_DOMAIN}@'"$PROXY_DOMAIN"'@g' $SITE_CONF_FILE
		sed -i.bak 's@{PROXY_ADDRESS}@'"$PROXY_ADDRESS"'@g' $SITE_CONF_FILE

		# Check if we already created the certificates
		CERTS_EXIST=false

		if [ -f /etc/letsencrypt/live/$PROXY_DOMAIN/fullchain.pem ]; then
			if [ -f /etc/letsencrypt/live/$PROXY_DOMAIN/privkey.pem ]; then
				CERTS_EXIST=true
			fi
		fi

		if [ "$CERTS_EXIST" = "false" ]; then
			./create.sh $SITE_CONF_FILE
		fi

	done

else

    SITE_CONF_FILE=$(ls -d -1 /nginx-letsencrypt/**)

    # Get the hosts names
    CONTENT=$(cat $SITE_CONF_FILE | grep server_name)
    RE='.*server_name(.*);'
    [[ $CONTENT =~ $RE ]]
    HOSTS=${BASH_REMATCH[1]}
    HOSTS=$(echo $HOSTS | xargs)

    # Check if we already created the certificates
    CERTS_EXIST=false

    if [ -f /etc/letsencrypt/live/$HOSTS/fullchain.pem ]; then
        if [ -f /etc/letsencrypt/live/$HOSTS/privkey.pem ]; then
            CERTS_EXIST=true
        fi
    fi

    if [ "$CERTS_EXIST" = "false" ]; then
        ./create.sh $SITE_CONF_FILE
    fi

fi

echo "Starting nginx as daemon"
nginx -g 'daemon off;'

