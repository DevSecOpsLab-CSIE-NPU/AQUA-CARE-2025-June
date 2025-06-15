#!/usr/bin/env bash

set -euo pipefail

# Set credentials and endpoint
ES_URL="https://localhost:9200"

# 1️⃣ 取得 basic auth 帳號與密碼
ES_USER=$(kubectl get secret elasticsearch-master-credentials \
  -o jsonpath="{.data.username}" | base64 --decode)
ES_PASS=$(kubectl get secret elasticsearch-master-credentials \
  -o jsonpath="{.data.password}" | base64 --decode)

echo "Using ES account: $ES_USER $ES_PASS"

# Create API key for iot-* index write access
API_JSON=$(curl -k -X POST -u "$ES_USER:$ES_PASS" \
  "$ES_URL/_security/api_key" \
  -H "Content-Type: application/json" \
  -d '{
        "name": "iot-key",
        "expiration": "30d",
        "role_descriptors": {
          "iot_writer": {
            "cluster": ["monitor","manage_own_api_key"],
            "indices": [{
              "names": ["iot-*"],
              "privileges": ["create_index","create","index","write"]
            }]
          }
        }
      }')

echo "API Key response:"
echo "$API_JSON" | jq .

APIKEY=$(echo "$API_JSON" | jq -r .encoded)

if [ -z "$APIKEY" ] || [ "$APIKEY" == "null" ]; then
  echo "❌ Failed to get API key!"
  exit 1
fi

echo "🌟 API Key created and encoded: $APIKEY"
