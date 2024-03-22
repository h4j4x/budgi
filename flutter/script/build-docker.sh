#!/bin/bash

if [ -z "$1" ]; then
    echo "Enter Spring Server URL!"
    exit 1
fi

flutter build web --release --dart-define="DATA_PROVIDER=spring" --dart-define="SPRING_URL=$1"
docker build -t ghcr.io/h4j4x/budgi-app:latest .
