# Ansible 專案

本專案旨在透過 Ansible 進行配置管理與自動化。以下簡要介紹本專案的各個組件。

## 目錄結構

- **inventories/**：包含定義 playbook 目標主機的 inventory 檔案。
  - **hosts.ini**：指定目標機器及其連線資訊。

- **playbooks/**：存放主要的 playbook 檔案。
  - **site.yml**：主要的 playbook，負責協調指定主機上的任務。

## 快速開始

```
bash tools/install_ansbile.sh
source .venv/bin/activate
pip install ansible
ansible-playbook -i ansible/inventories/hosts.ini ansible/playbooks/install_k3s.yaml
source ~/.bashrc
k get po -A

```

## 授權

本專案採用 MIT 授權。詳情請參閱 LICENSE 檔案。
