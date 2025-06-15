# Ansible 專案

本專案旨在透過 Ansible 進行配置管理與自動化。以下簡要介紹本專案的各個組件。

## 目錄結構

- **inventories/**：包含定義 playbook 目標主機的 inventory 檔案。
  - **hosts.ini**：指定目標機器及其連線資訊。

- **playbooks/**：存放主要的 playbook 檔案。
  - **site.yml**：主要的 playbook，負責協調指定主機上的任務。

- **roles/**：包含封裝任務、處理程序、模板和變數的角色。
  - **common/**：包含常用任務與配置的角色。
    - **tasks/**：存放該角色的主要任務。
      - **main.yml**：定義要在目標主機上執行的動作。
    - **handlers/**：存放當其他任務通知時執行的處理程序。
      - **main.yml**：定義該角色的處理程序。
    - **templates/**：用於存放 Jinja2 模板檔案，以動態產生配置。
    - **files/**：存放可複製到目標主機的靜態檔案。
    - **vars/**：存放該角色專用的變數。
      - **main.yml**：定義任務與模板中使用的變數。

## 快速開始

請依照以下步驟開始使用本 Ansible 專案：



## 授權

本專案採用 MIT 授權。詳情請參閱 LICENSE 檔案。