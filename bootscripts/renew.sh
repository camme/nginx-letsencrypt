#!/bin/bash

set -e

echo "Renewing certs"
service nginx start
certbot renew
service nginx stop
