#!/bin/bash
exec > /var/log/user-data.log 2>&1
set -x

# ============================================
# 1. Instalar nginx (Amazon Linux 2)
# ============================================
sudo amazon-linux-extras install nginx1 -y

# ============================================
# 2. Iniciar nginx
# ============================================
sudo systemctl start nginx
sudo systemctl enable nginx

# ============================================
# 3. Obtener metadata
# ============================================
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
AZ=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/availability-zone)

# ============================================
# 4. Crear página web
# ============================================
cat > /usr/share/nginx/html/index.html << HTML
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>TechNova Solutions</title>
    <style>
        body { font-family: 'Segoe UI', Arial, sans-serif; text-align: center; margin: 0; padding: 0; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; display: flex; align-items: center; justify-content: center; }
        .container { background: white; padding: 40px; border-radius: 20px; box-shadow: 0 20px 60px rgba(0,0,0,0.3); max-width: 500px; }
        h1 { color: #2c3e50; margin-bottom: 10px; }
        h2 { color: #764ba2; margin-top: 0; font-weight: 400; }
        .info { background: #f8f9fa; padding: 20px; border-radius: 10px; margin-top: 20px; }
        .info p { margin: 10px 0; color: #555; }
        .highlight { color: #764ba2; font-weight: bold; }
        .status { color: #27ae60; font-weight: bold; }
    </style>
</head>
<body>
    <div class="container">
        <h1>TechNova Solutions</h1>
        <h2>Alta Disponibilidad en AWS</h2>
        <div class="info">
            <p>Instancia: <span class="highlight">${INSTANCE_ID}</span></p>
            <p>Zona de Disponibilidad: <span class="highlight">${AZ}</span></p>
            <p>Estado: <span class="status">✓ Operativo</span></p>
        </div>
    </div>
</body>
</html>
HTML

# ============================================
# 5. Verificar que nginx responde
# ============================================
curl -I http://localhost:80

# ============================================
# 6. Instalar CloudWatch Agent (opcional)
# ============================================
# Descargar e instalar CloudWatch Agent
wget -q https://amazoncloudwatch-agent.s3.amazonaws.com/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
sudo rpm -U amazon-cloudwatch-agent.rpm
rm -f amazon-cloudwatch-agent.rpm

# Configuración básica de CloudWatch Agent
sudo mkdir -p /opt/aws/amazon-cloudwatch-agent/etc
sudo cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << 'EOF'
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
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

echo "Setup completed successfully"