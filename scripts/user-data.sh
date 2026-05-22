#!/bin/bash
exec > /var/log/user-data.log 2>&1
set -x

yum update -y
yum install -y docker

systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${ecr_repository_url}

for i in $(seq 1 30); do
  docker pull ${ecr_repository_url}:${app_version} && break
  echo "Intento $i fallo, esperando 10s..."
  sleep 10
done

TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $$TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
AZ=$(curl -s -H "X-aws-ec2-metadata-token: $$TOKEN" http://169.254.169.254/latest/meta-data/placement/availability-zone)

docker run -d \
  --name technova-web \
  -p 80:80 \
  -e INSTANCE_ID="$${INSTANCE_ID}" \
  -e AZ="$${AZ}" \
  -e APP_VERSION="${app_version}" \
  --restart unless-stopped \
  ${ecr_repository_url}:${app_version}
