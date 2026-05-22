#!/bin/bash
exec > /var/log/user-data.log 2>&1
set -x

# ============================================
# 1. Instalar y configurar nginx
# ============================================
yum update -y
yum install -y nginx

TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
AZ=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/availability-zone)

cat > /usr/share/nginx/html/index.html << HTML
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>TechNova Solutions</title>
    <style>
        body { font-family: Arial; text-align: center; padding: 50px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; display: flex; align-items: center; justify-content: center; }
        .container { background: white; padding: 40px; border-radius: 20px; }
        h1 { color: #2c3e50; }
        .highlight { color: #764ba2; font-weight: bold; }
        .status { color: #27ae60; }
    </style>
</head>
<body>
    <div class="container">
        <h1>TechNova Solutions</h1>
        <h2>Alta Disponibilidad en AWS</h2>
        <p>Instancia: <span class="highlight">${INSTANCE_ID}</span></p>
        <p>Zona: <span class="highlight">${AZ}</span></p>
        <p class="status">✓ Sistema Operativo</p>
    </div>
</body>
</html>
HTML

systemctl start nginx
systemctl enable nginx

# ============================================
# 2. Instalar CloudWatch Agent (sin wget)
# ============================================
# Usar rpm desde S3 (accesible desde AWS)
curl -o /tmp/cw-agent.rpm https://amazoncloudwatchagent.s3.amazonaws.com/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
rpm -U /tmp/cw-agent.rpm 2>/dev/null || true
rm -f /tmp/cw-agent.rpm

# Configurar CloudWatch Agent
mkdir -p /opt/aws/amazon-cloudwatch-agent/etc
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << 'EOF'
{
  "metrics": {
    "metrics_collected": {
      "cpu": {"measurement": ["cpu_usage_user"], "metrics_collection_interval": 60},
      "mem": {"measurement": ["mem_used_percent"], "metrics_collection_interval": 60}
    }
  }
}
EOF

# Iniciar CloudWatch Agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

echo "Setup completed successfully"