#!/usr/bin/env bash

set -euo pipefail

# 1️⃣ 取得 basic auth 帳號與密碼
ES_ACCOUNT=$(kubectl get secret elasticsearch-master-credentials \
  -o jsonpath="{.data.username}" | base64 --decode)
ES_PASSWORD=$(kubectl get secret elasticsearch-master-credentials \
  -o jsonpath="{.data.password}" | base64 --decode)

echo "Using ES account: $ES_ACCOUNT"

# 2️⃣ 建立 API Key（有效期30天，限制對 iot-* index 的寫入）
API_JSON=$(curl -X POST -u "$ES_ACCOUNT:$ES_PASSWORD" \
  http://202.5.254.156:32000/_security/api_key \
  -H "Content-Type: application/json" \
  -d '{
        "name": "iot-key",
        "expiration": "30d",
        "role_descriptors": {
          "iot_writer": {
            "cluster": ["manage_own_api_key"],
            "indices": [{
              "names": ["iot-*"],
              "privileges": ["create_index","create","index","write"]
            }]
          }
        }
      }')

echo "API Key response:"
echo $API_JSON
echo "$API_JSON" | jq .

APIKEY=$(echo "$API_JSON" | jq -r .encoded)

if [ -z "$APIKEY" ] || [ "$APIKEY" == "null" ]; then
  echo "❌ Failed to get API key!"
  exit 1
fi

echo "🌟 API Key created and encoded."

# 3️⃣ 使用 API Key 存取 /_cluster/health
echo "Testing with API Key:"
curl -s -H "Authorization: ApiKey $APIKEY" \
     http://elasticsearch.default.svc.cluster.local:9200/_cluster/health?pretty
echo

