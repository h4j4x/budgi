#!/bin/bash

if [ -z "$1" ]; then
    echo "Enter new version!"
    exit 1
fi

version=$(cat "VERSION")
sed -i "s/$version/$1/" ./VERSION
sed -i "s/version: $version/version: $1/" ./flutter/pubspec.yaml
sed -i "s/version=$version/version=$1/" ./spring/gradle.properties
