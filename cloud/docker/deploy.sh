#!/bin/bash

serverUrl=""
if [ -e "SERVER_URL" ]; then
    serverUrl=$(cat "SERVER_URL")
fi

if [ -n "$1" ]; then
    serverUrl="$1"
fi

if [ -z "$serverUrl" ]; then
    echo "Enter server URL!"
    exit 1
fi

echo $serverUrl > ./SERVER_URL

if [ -d "./budgi" ]; then
    # Delete old directory
    rm -rf ./budgi/
fi
mkdir -p vol

oldVersion="0.0.0"
if [ -e "VERSION" ]; then
    oldVersion=$(cat "VERSION")
fi

git clone https://github.com/h4j4x/budgi.git

version=$(cat "./budgi/VERSION")
if [ "$oldVersion" = "$version" ]; then
    echo "Up to date on version $version."
    rm -rf ./budgi/
else
    echo "Updating from $oldVersion to $version..."

    docker compose down

    cp -rf budgi/VERSION ./VERSION
    cp -rf budgi/cloud/docker/cfg/ ./cfg/
    cp -rf budgi/cloud/docker/compose.yml ./compose.yml
    rm -rf ./budgi/

    sed -i "s/SERVER_URL/$serverUrl/g" ./cfg/nginx/budgi.conf

    docker compose pull
    docker compose up -d

    echo "Done. Updated to $version!"
fi
