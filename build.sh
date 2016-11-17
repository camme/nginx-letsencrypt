#!/bin/bash

SERVICE_NAME=nginx-letsencrypt
SERVICE_VERSION=latest
REGISTRY=registry.1001.io
VERSION="$(git rev-list HEAD --count)-$(git rev-parse --short HEAD)"

# exit on error
set -e

# tag
echo "Building version $(git rev-parse --short HEAD)"
echo $(git rev-parse --short HEAD) > version.txt

export TAG_NAME="${SERVICE_NAME}:${SERVICE_VERSION}"

docker build --build-arg VERSION="$VERSION" --rm=true -t $TAG_NAME -f ./Dockerfile .

echo "Done."
