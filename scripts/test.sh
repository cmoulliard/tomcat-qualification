#!/usr/bin/env bash

ENDPOINT="https://localhost:8443/"
if [[ $ENDPOINT = "https"* ]]; then CURL_PARAMS="-k"; fi

echo "Params : $CURL_PARAMS"

curl $CURL_PARAMS --write-out %{http_code} --silent --output /dev/null $ENDPOINT

echo ""

curl $CURL_PARAMS -s $ENDPOINT