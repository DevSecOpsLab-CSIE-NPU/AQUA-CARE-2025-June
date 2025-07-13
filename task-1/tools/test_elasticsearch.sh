#!/usr/bin/env bash
set -eux

# 1. 指定 Elasticsearch 叢集名稱
ES_NAME="quickstart"

# 2. 取得 elastic 使用者密碼
PASSWORD=$(kubectl get secret "${ES_NAME}-es-elastic-user" \
  -o go-template='{{.data.elastic | base64decode}}')
echo "🔐 已取回 elastic 使用者的密碼。"

# 3. 在 Kubernetes 叢集中，以 Pod 執行 curl 測試
echo -e "\n🌐 在叢集內部測試連線："
kubectl run --rm -i curl-test \
  --image=curlimages/curl --restart=Never -- sh -c \
  "curl -u elastic:\"$PASSWORD\" -k \"https://${ES_NAME}-es-http:9200\""

# 4. 在本地透過 Port‑Forward 測試連線
echo -e "\n🔌 在本地 Port‑Forward 測試："
kubectl port-forward svc/"${ES_NAME}-es-http" 9200:9200 &
PF_PID=$!
trap "kill $PF_PID" EXIT

sleep 2

curl -u "elastic:${PASSWORD}" -k "https://localhost:9200"

echo -e "\n✅ Elasticsearch 試連線成功！"

