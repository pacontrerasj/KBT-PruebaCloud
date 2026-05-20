#!/bin/bash
# CloudWatch Agent Installation Script
# This script can be used separately for manual CloudWatch Agent installation

set -e

echo "Installing CloudWatch Agent..."

# Detect OS type
if [ -f /etc/system-release ]; then
    OS_TYPE=$(cat /etc/system-release | awk '{print $1}')
else
    OS_TYPE=$(cat /etc/os-release | grep "^NAME" | cut -d'"' -f2 | awk '{print $1}')
fi

case "$OS_TYPE" in
    "Amazon")
        echo "Detected Amazon Linux"
        wget https://amazoncloudwatchagent.s3.amazonaws.com/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
        rpm -U ./amazon-cloudwatch-agent.rpm
        rm -f amazon-cloudwatch-agent.rpm
        ;;
    "Ubuntu"|"Debian")
        echo "Detected Ubuntu/Debian"
        wget https://amazoncloudwatchagent.s3.amazonaws.com/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
        dpkg -i ./amazon-cloudwatch-agent.deb
        rm -f amazon-cloudwatch-agent.deb
        ;;
    "RHEL"|"CentOS")
        echo "Detected RHEL/CentOS"
        wget https://amazoncloudwatchagent.s3.amazonaws.com/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
        rpm -U ./amazon-cloudwatch-agent.rpm
        rm -f amazon-cloudwatch-agent.rpm
        ;;
    *)
        echo "Unsupported OS: $OS_TYPE"
        exit 1
        ;;
esac

# Create CloudWatch Agent configuration
mkdir -p /opt/aws/amazon-cloudwatch-agent/etc

cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << 'EOF'
{
  "agent": {
    "run_as_user": "root"
  },
  "metrics": {
    "namespace": "TechNova/Compute",
    "metrics_collected": {
      "cpu": {
        "measurement": [
          "cpu_usage_idle",
          "cpu_usage_iowait",
          "cpu_usage_user",
          "cpu_usage_system"
        ],
        "metrics_collection_interval": 60
      },
      "disk": {
        "measurement": [
          "used",
          "used_percent",
          "inodes_free"
        ],
        "metrics_collection_interval": 60,
        "drop_device": false
      },
      "mem": {
        "measurement": [
          "mem_used",
          "mem_available",
          "mem_total"
        ],
        "metrics_collection_interval": 60
      },
      "netstat": {
        "measurement": [
          "tcp_established",
          "tcp_time_wait"
        ],
        "metrics_collection_interval": 60
      },
      "process": {
        "measurement": [
          "process_count"
        ],
        "metrics_collection_interval": 60,
        "collect_list": [
          {
            "name": "docker",
            "exact_match": "docker"
          },
          {
            "name": "nginx",
            "exact_match": "nginx"
          }
        ]
      }
    }
  }
}
EOF

# Start CloudWatch Agent
echo "Starting CloudWatch Agent..."
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

echo "CloudWatch Agent installation completed!"