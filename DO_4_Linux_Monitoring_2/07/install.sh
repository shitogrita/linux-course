#!/usr/bin/env bash

set -euo pipefail

PROM_VERSION="3.10.0"
NODE_VERSION="1.10.2"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

install_base() {
    apt update
    apt install -y wget curl tar gnupg apt-transport-https adduser libfontconfig1
}

install_prometheus() {
    cd /tmp
    rm -rf "prometheus-${PROM_VERSION}.linux-amd64"
    wget -O "prometheus-${PROM_VERSION}.linux-amd64.tar.gz" \
        "https://github.com/prometheus/prometheus/releases/download/v${PROM_VERSION}/prometheus-${PROM_VERSION}.linux-amd64.tar.gz"
    tar -xzf "prometheus-${PROM_VERSION}.linux-amd64.tar.gz"

    useradd --no-create-home --shell /usr/sbin/nologin prometheus 2>/dev/null || true

    mkdir -p /etc/prometheus /var/lib/prometheus
    cp "/tmp/prometheus-${PROM_VERSION}.linux-amd64/prometheus" /usr/local/bin/
    cp "/tmp/prometheus-${PROM_VERSION}.linux-amd64/promtool" /usr/local/bin/
    cp "$SCRIPT_DIR/prometheus.yml" /etc/prometheus/prometheus.yml

    chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus
    chown prometheus:prometheus /usr/local/bin/prometheus /usr/local/bin/promtool

    cat > /etc/systemd/system/prometheus.service <<'EOF'
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus \
  --web.listen-address=0.0.0.0:9090

Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable --now prometheus
}

install_node_exporter() {
    cd /tmp
    rm -rf "node_exporter-${NODE_VERSION}.linux-amd64"
    wget -O "node_exporter-${NODE_VERSION}.linux-amd64.tar.gz" \
        "https://github.com/prometheus/node_exporter/releases/download/v${NODE_VERSION}/node_exporter-${NODE_VERSION}.linux-amd64.tar.gz"
    tar -xzf "node_exporter-${NODE_VERSION}.linux-amd64.tar.gz"

    useradd --no-create-home --shell /usr/sbin/nologin node_exporter 2>/dev/null || true
    cp "/tmp/node_exporter-${NODE_VERSION}.linux-amd64/node_exporter" /usr/local/bin/
    chown node_exporter:node_exporter /usr/local/bin/node_exporter

    cat > /etc/systemd/system/node_exporter.service <<'EOF'
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter --web.listen-address=0.0.0.0:9100

Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable --now node_exporter
}

install_grafana() {
    mkdir -p /etc/apt/keyrings
    wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor -o /etc/apt/keyrings/grafana.gpg
    echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" \
        > /etc/apt/sources.list.d/grafana.list

    apt update
    apt install -y grafana
    systemctl enable --now grafana-server
}

install_stress() {
    apt install -y stress
}

main() {
    install_base
    install_prometheus
    install_node_exporter
    install_grafana
    install_stress

    echo "Prometheus:  http://<VM_IP>:9090"
    echo "Node Exporter metrics: http://<VM_IP>:9100/metrics"
    echo "Grafana:     http://<VM_IP>:3000"
    echo "Grafana first login: admin / admin"
}

main "$@"