cd ~/Documentos/KBT_CLOUD/Pruebav2/scripts

cat > user-data.sh << 'EOF'
#!/bin/bash
exec > /var/log/user-data.log 2>&1
set -x

# Instalar Docker
sudo yum update -y
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -a -G docker ec2-user
sudo usermod -a -G docker ssm-user

# Instalar Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Crear aplicación
mkdir -p /home/ec2-user/app
cd /home/ec2-user/app

cat > docker-compose.yml << 'DOCKEREOF'
version: '3'
services:
  nginx:
    image: nginx:alpine
    container_name: technova-nginx
    ports:
      - "80:80"
    restart: always
    volumes:
      - ./html:/usr/share/nginx/html
DOCKEREOF

# Crear página web
mkdir -p html
cat > html/index.html << 'HTMLEOF'
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>TechNova Solutions</title>
    <style>
        body { font-family: Arial; text-align: center; padding: 50px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; display: flex; align-items: center; justify-content: center; margin: 0; }
        .container { background: white; padding: 40px; border-radius: 20px; }
        h1 { color: #2c3e50; }
        h2 { color: #764ba2; }
        .status { color: #27ae60; font-weight: bold; }
    </style>
</head>
<body>
    <div class="container">
        <h1>TechNova Solutions</h1>
        <h2>Alta Disponibilidad en AWS</h2>
        <p class="status">✅ Despliegue Automatizado con Terraform</p>
    </div>
</body>
</html>
HTMLEOF

# Iniciar contenedor
/usr/local/bin/docker-compose up -d

echo "Setup completed successfully"
EOF