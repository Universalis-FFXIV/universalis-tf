```sh
./prometheus-config.sh --compose
./grafana-datasource.sh --compose
./generate-dashboards.sh -t -v 5.1
cp ./* /scylla-monitoring-stack -r
mkdir /scylla-monitoring-stack/grafana/data
mkdir /scylla-monitoring-stack/prometheus/data
# Overwrite files with the ones here...
```