#!/usr/bin/env bash

set -euo pipefail

# 1️⃣ 取得 basic auth 帳號與密碼
ES_ACCOUNT=$(kubectl get secret elasticsearch-master-credentials \
  -o jsonpath="{.data.username}" | base64 --decode)
ES_PASSWORD=$(kubectl get secret elasticsearch-master-credentials \
  -o jsonpath="{.data.password}" | base64 --decode)

echo "Using ES account: $ES_ACCOUNT $ES_PASSWORD"

# 取得 Elasticsearch Service 的 exposed PORT
ES_SVC_NAME="elasticsearch-master"
ES_NAMESPACE="default"
ES_PORT=$(kubectl get svc $ES_SVC_NAME -n $ES_NAMESPACE -o jsonpath='{.spec.ports[?(@.name=="http")].port}')
if [ -z "$ES_PORT" ]; then
  echo "❌ Could not determine Elasticsearch service port."
  exit 1
fi
# 取得本機外部 IP
ES_HOST=$(curl -s ifconfig.me)
ES_URL="https://$ES_HOST:$ES_PORT"
echo "Elasticsearch URL: $ES_URL"

# 測試 Elasticsearch 是否可用
response=$(curl -k -s -o /dev/null -w "%{http_code}" -u "$ES_ACCOUNT:$ES_PASSWORD" "$ES_URL")
if [ "$response" -eq 200 ]; then
  echo "✅ Elasticsearch is available."
else
  echo "❌ Elasticsearch is not available. HTTP status: $response"
  exit 1
fi
# 列出所有 Elasticsearch 索引
echo "Fetching Elasticsearch index list..."
curl -k -s -u "$ES_ACCOUNT:$ES_PASSWORD" "$ES_URL/_cat/indices?v"
