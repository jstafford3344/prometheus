#!/bin/bash

SERVICE_PATH="/etc/systemd/system/prometheus.service"

# Add prometheus user
sudo useradd --no-create-home --shell /bin/false prometheus

sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus

sudo chown prometheus:prometheus /etc/prometheus/
sudo chown prometheus:prometheus /var/lib/prometheus/

# Get specific version of Prometheus from GH
sudo wget https://github.com/prometheus/prometheus/releases/download/v2.53.4/prometheus-2.53.4.linux-amd64.tar.gz
sudo tar -xvzf prometheus-2.53.4.linux-amd64.tar.gz
cd prometheus-2.53.4.linux-amd64/

# Copy to executable dir
sudo cp prometheus /usr/local/bin/
sudo cp promtool /usr/local/bin/
sudo cp -r consoles /etc/prometheus
sudo cp -r console_libraries /etc/prometheus
sudo cp prometheus.yml /etc/prometheus/prometheus.yml


sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool
sudo chown -R prometheus:prometheus /etc/prometheus/consoles
sudo chown -R prometheus:prometheus /etc/prometheus/console_libraries
sudo chown prometheus:prometheus /etc/prometheus/prometheus.yml

# Set up systemd
cat > "$SERVICE_PATH" <<EOF
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
  --config.file /etc/prometheus/prometheus.yml \
  --storage.tsdb.path /var/lib/prometheus \
  --web.console.templates=/etc/prometheus/consoles \
  --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOF

# Start Prometheus via systemd
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus
