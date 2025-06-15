#!/usr/bin/env bash

set -euo pipefail

# Set your API key here
ES_APIKEY="Nk5ZOGM1Y0JkVjVWNTl1REo3RXk6Y3pyTXJsX3BSdTJweUpBYlBob0VSUQ=="  # <-- Replace with your actual API key
ES_URL="https://localhost:9200"

# Example: Query cluster health using API key
curl -k -H "Authorization: ApiKey $ES_APIKEY" \
     "$ES_URL/_cluster/health?pretty"
echo
