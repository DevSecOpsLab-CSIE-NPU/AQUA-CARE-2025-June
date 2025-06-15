
```
cd elk/
helm install elasticsearch elastic/elasticsearch -f elasticsearch/values.yml
helm install filebeat elastic/filebeat -f filebeat/values.yml
helm install logstash elastic/logstash -f  logstash/values.yml
helm install kibana elastic/kibana -f kibana/values.yml
```
