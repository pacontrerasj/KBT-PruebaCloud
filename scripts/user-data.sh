#!/bin/bash
exec > /var/log/user-data.log 2>&1
set -x

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
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Technova Solutions</title>
    <style>
        body { font-family: 'Segoe UI', Arial, sans-serif; text-align: center; margin: 0; padding: 0; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; display: flex; align-items: center; justify-content: center; }
        .container { background: white; padding: 40px; border-radius: 20px; box-shadow: 0 20px 60px rgba(0,0,0,0.3); max-width: 500px; }
        h1 { color: #2c3e50; margin-bottom: 10px; }
        h2 { color: #764ba2; margin-top: 0; font-weight: 400; }
        .info { background: #f8f9fa; padding: 20px; border-radius: 10px; margin-top: 20px; }
        .info p { margin: 10px 0; color: #555; }
        .highlight { color: #764ba2; font-weight: bold; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Technova Solutions</h1>
        <h2>Alta Disponibilidad</h2>
        <div class="info">
            <p>Instancia: <span class="highlight">${INSTANCE_ID}</span></p>
            <p>Zona: <span class="highlight">${AZ}</span></p>
        </div>
    </div>
</body>
</html>
HTML

systemctl start nginx
systemctl enable nginx
