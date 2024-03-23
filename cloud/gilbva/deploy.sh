#!/bin/bash

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
    cp -rf budgi/cloud/gilbva/cfg/ ./cfg/
    cp -rf budgi/cloud/gilbva/compose.yml ./compose.yml
    rm -rf ./budgi/

    docker compose pull
    docker compose up -d

    echo "Done. Updated to $version!"
fi
