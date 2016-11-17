#!/bin/bash

SERVICE_NAME=nginx-letsencrypt
SERVICE_VERSION=latest
REGISTRY=registry.1001.io
VERSION="$(git rev-list HEAD --count)-$(git rev-parse --short HEAD)"

# exit on error
set -e

# tag
echo "Creating version $(git rev-parse --short HEAD)"
echo $(git rev-parse --short HEAD) > version.txt
# echo $(git describe --exact-match --tags $(git log -n1 --pretty='%h'))

export TAG_NAME="${SERVICE_NAME}:${SERVICE_VERSION}"

docker build --build-arg VERSION="$VERSION" --rm=true -t $TAG_NAME -f ../Dockerfile.prod ../

echo "Tagging with $TAG_NAME"

docker tag $TAG_NAME $REGISTRY/$TAG_NAME

echo "Pushing $TAG_NAME"

docker push $REGISTRY/$TAG_NAME

echo "Done."
