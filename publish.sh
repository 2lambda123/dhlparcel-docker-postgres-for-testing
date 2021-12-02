#! /bin/bash

TAG=$(grep -oP '(?<=postgres:).*' ./Dockerfile)

echo "Using TAG from Dockerfile: '$TAG'"

docker build -t dhlparcel/dhl-parcel-build-postgres:$TAG .
docker push dhlparcel/dhl-parcel-build-postgres:$TAG
