# add data node

1. using eck-operator with helm
2. use 8.16.1


## 1 node config
ref: [here](https://www.elastic.co/docs/deploy-manage/deploy/cloud-on-k8s/elasticsearch-deployment-quickstart)

---

### 🗂️ 第一步：進入專案資料夾

```bash
cd AQUA-CARE-2025-June/
ls
cd task-1/
ls
```

* 切換至專案主目錄，再進入 `task-1` 子資料夾，裡面準備進行 Elasticsearch 與 Kibana 的部署。

---

### 🧱 第二步：建置 step1 狀態夾

```bash
mkdir step1
cd step1/
ls
```

* 建立 `step1` 資料夾作為本次任務的工作目錄。

---

### 🚀 第三步：部署 Elasticsearch

```bash
vi elasticsearch.yml
k apply -f elasticsearch.yml
```

* 編輯 `elasticsearch.yml` （包含 Elasticsearch CR 定義）。
* 使用 `kubectl apply` （簡寫 `k`）進行部署。

```bash
k get po -A
kubectl describe crd elasticsearch | more
kubectl get elasticsearch
```

* 想確認 CRD 是否已建立，查看 Clusters、Pods 狀態。

```bash
k logs quickstart-es-default-0 -f
k describe pod quickstart-es-default-0
k get po -A
```

* 追蹤 Elasticsearch 控制器 Pod `quickstart-es-default-0` 的日誌，及詳細描述 Pod 狀態。

---

### 📌 第四步：部署 Kibana

```bash
vi kibana.yml
k apply -f kibana.yml
k get po -A
```

* 創建並套用 `kibana.yml`，部署 Kibana。
* 使用 `kubectl get po -A` 確認 Kibana Pod 是否啟動成功。

---

### 🧰 第五步：準備驗證腳本

```bash
ls
cd ..
ls
mkdir tools
cd tools/
ls
vi test_elasticsearch.sh
bash test_elasticsearch.sh
```

* 在 `task-1` 中創建 `tools` 資料夾，編輯 `test_elasticsearch.sh` 測試腳本。
* 執行此腳本，檢查 Elasticsearch 是否可用。

```bash
vi test_elasticsearch.sh
bash test_elasticsearch.sh
ls
cd ..
ls
k get po -A
```

* 如有需要，重新編輯並執行腳本、再次確認 Pod 狀態。

---

### 🔗 第六步：開啟 Kibana 端口轉發

```bash
kubectl port-forward service/quickstart-kb-http 5601
```

* 將集群內的 Kibana Service 轉發至本地 5601 埠，以便本地瀏覽器訪問。
* 此後可使用瀏覽器開啟 `http://localhost:5601`，進入 Kibana UI。

---

### 📑 第七步：檢視歷史指令

```bash
history
```

* 列出所有執行過的命令，方便複製或記錄本次操作過程。

---

## ✔️ 小結

1. 切換到 `task-1/step1`，部署 Elasticsearch 並檢查 Pod 狀態。
2. 使用類似步驟部署 Kibana。
3. 編寫測試腳本 `test_elasticsearch.sh`，驗證 Elasticsearch API 可連通。
4. 使用 `kubectl port-forward` 將 Kibana 暴露到本地端。

## 2 master+data node
ref: [here](https://www.elastic.co/docs/deploy-manage/deploy/cloud-on-k8s/nodes-orchestration)

---

### 🗑️ 步驟 1：清除舊部署

```bash
kubectl delete -f kibana.yml
kubectl delete -f kibana.yml elastic
kubectl delete -f kibana.yml elasticsearch.
kubectl delete -f *.yml
```

* 刪除之前部署的 Kibana 和 Elasticsearch 資源（用 `.yml` 檔案），確保環境重置。
* `-f *.yml` 將所有 YAML 檔一起清理乾淨。

```bash
ls
k delete -f elasticsearch.yml
ls
k get po -A
```

* 確認 `elasticsearch.yml` 是否還存在，若在則刪除。
* `kubectl get pods -A` 檢查是否仍有相關 Pod 殘留。

---

### 📁 步驟 2：建立新工作目錄

```bash
cd ..
ls
mkdir step2
cd step2/
ls
```

* 回到上層目錄，建立 `step2` 資料夾準備新的部署階段。

---

### 🚀 步驟 3：部署 Elasticsearch（第二階段）

```bash
vi elasticsearch.yml
k apply -f elasticsearch.yml
k get po -A
k get pvc
```

* 撰寫新的 `elasticsearch.yml` CR 檔。
* 部署 Elasticsearch。
* 查看 Pod 和 PVC 狀態確認正常建立。

---

### 📄 步驟 4：撰寫與套用 PV/PVC 定義

```bash
ls
vi pvc.yml
mkdir pvc-master
mkdir pvc-data
pwd
vi pvc.yml
k apply -f pvc
k apply -f pvc.yml
```

* 建立 `pvc.yml`，定義 PersistentVolume（PV）。
* 建立兩個資料夾 `pvc-master` 和 `pvc-data`（用於儲存 PV 對應宿主機路徑）。
* `k apply -f pvc.yml`：將 PV 服務配置套用到叢集。

```bash
k get po -A
k get pvc -A
```

* 確認 Pod 正常運作與 PVC 是否已經綁定到 PV。

---

### 🔍 步驟 5：觀察 Pod 日誌與狀態

```bash
k describe pod quickstart-es-master-nodes-0
k logs quickstart-es-master-nodes-0
k logs -f quickstart-es-master-nodes-0
k logs -f quickstart-es-data-nodes-0
k get po -A
```

* `describe` 查看 master 節點詳細狀態。
* `logs`：查看 master 與 data 節點日誌並跟隨輸出中 debug 問題。

---

### ✅ 步驟 6：測試 Elasticsearch 服務

```bash
bash ../tools/test_elasticsearch.sh
```

* 使用事先撰寫的測試腳本來驗證 Elasticsearch 是否可以正常連線與操作。

---

### 🎯 步驟 7：重新部署 Kibana

```bash
k apply -f ../step1/kibana.yml
k get po -A
```

* 套用之前已準備好的 `kibana.yml`（可能在第一階段）。
* `get po` 確認 Kibana Pod 也已成功啟動。

### 步驟 8：在 Kibana 中確認儲存容量
https://localhost:5601/app/dev_tools#/console/shell

![img](https://private-user-images.githubusercontent.com/35834182/465764090-1460ca19-537f-4547-a65f-0b20b9f05a90.png?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3NTI0MjkyMDEsIm5iZiI6MTc1MjQyODkwMSwicGF0aCI6Ii8zNTgzNDE4Mi80NjU3NjQwOTAtMTQ2MGNhMTktNTM3Zi00NTQ3LWE2NWYtMGIyMGI5ZjA1YTkwLnBuZz9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNTA3MTMlMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjUwNzEzVDE3NDgyMVomWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPThlM2ZlYmFhYWNhYjczODMwZDUwZDg3MGU5ODUwNzdiZThjZjUxYmI1YzVhODk2NjU2M2RkM2IyZjc4ZjQ5ZDAmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0In0.c-wSJB3UvsfJf3com7_17LsJ_U1wwvRIQUoPdnyB7xM)

左邊依次指令為
```
GET /_cat/allocation?v  # 容量
GET /_cat/indices?v # 已建置索引
GET /_nodes/stats/fs # 節點現況

```


---

### 📌 小結

| 階段                  | 操作重點                         |
| ------------------- | ---------------------------- |
| 清理部署                | 刪除所有原有資源，重新建立乾淨環境            |
| 分階段部署 Elasticsearch | step1 無 PV，step2 增加靜態 PV/PVC |
| 監控 Pod 與日誌          | 確認 master/data 啟動無誤          |
| 測試連線                | 使用腳本驗證服務成功                   |
| 最後部署 Kibana         | 完成觀察層 Kibana 的套用啟動           |




