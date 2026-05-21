#!/bin/bash
cd /home/ec2-user

yum update -y
yum install -y docker

systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user

curl -L "https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

wget https://amazoncloudwatch-agent.s3.amazonaws.com/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
rpm -U ./amazon-cloudwatch-agent.rpm

TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
AZ=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/availability-zone)

mkdir -p /home/ec2-user/app/html

cat > /home/ec2-user/app/docker-compose.yml << 'COMPOSE'
version: '3.8'
services:
  web:
    image: nginx:latest
    ports:
      - "80:80"
    volumes:
      - /home/ec2-user/app/html:/usr/share/nginx/html:ro
    restart: always
COMPOSE

cat > /home/ec2-user/app/html/index.html << 'HTML'
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

cd /home/ec2-user/app
docker-compose up -d

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json