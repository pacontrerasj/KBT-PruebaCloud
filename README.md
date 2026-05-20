# TechNova Solutions - Infrastructure as Code

## Descripción

Proyecto de **Infraestructura como Código (IaC)** para **TechNova Solutions** usando **Terraform** y **GitHub Actions**.

## Arquitectura

```
┌─────────────────────────────────────────────────────────────┐
│                        VPC (10.0.0.0/16)                    │
├─────────────────────────────────────────────────────────────┤
│  ┌────────────────┐    ┌────────────────┐                   │
│  │   Public Subnet│    │  Public Subnet │                  │
│  │   us-east-1a   │    │  us-east-1b     │                  │
│  │  ┌──────────┐  │    │  ┌──────────┐  │                   │
│  │  │  NAT GW │  │    │  │  NAT GW  │  │                  │
│  │  └──────────┘  │    │  └──────────┘  │                  │
│  │  ┌──────────┐  │    │  ┌──────────┐  │                  │
│  │  │   ALB   │  │    │  │   ALB    │  │                  │
│  │  └──────────┘  │    │  └──────────┘  │                  │
│  └────────┬───────┘    └────────┬───────┘                   │
│           │                     │                           │
│  ┌────────┴─────────────────────┴───────────────┐           │
│  │           Private Subnets (App)              │           │
│  │   us-east-1a          us-east-1b             │           │
│  │  ┌──────────┐        ┌──────────┐            │           │
│  │  │ EC2(t3)  │◄──────►│ EC2(t3)  │            │           │
│  │  │ (Docker) │        │ (Docker) │            │           │
│  │  └──────────┘        └──────────┘            │           │
│  └───────────────────────┬───────────────────────┘           │
│                          │                                    │
│  ┌───────────────────────┴────────────────────────┐         │
│  │           Private Subnets (Data)                │         │
│  │   us-east-1a          us-east-1b                │         │
│  │  ┌──────────┐        ┌──────────┐              │         │
│  │  │  RDS     │◄──────►│  RDS     │ (Multi-AZ)    │         │
│  │  │ MySQL    │        │ MySQL    │              │         │
│  │  └──────────┘        └──────────┘              │         │
│  └─────────────────────────────────────────────────┘         │
└─────────────────────────────────────────────────────────────┘
```

## Estructura del Proyecto

```
.
├── environments/
│   └── dev/                    # Configuración del entorno de desarrollo
│       ├── main.tf             # Archivo principal de Terraform
│       ├── variables.tf        # Definición de variables
│       ├── outputs.tf          # Outputs del proyecto
│       ├── backend.tf          # Configuración del backend S3
│       ├── providers.tf        # Proveedor AWS
│       └── terraform.tfvars    # Variables (NO committing)
├── modules/
│   ├── networking/             # VPC, Subnets, NAT Gateway, IGW
│   ├── security/              # Security Groups
│   ├── compute/               # Launch Template, ASG
│   ├── loadbalancer/          # ALB, Target Group
│   ├── database/              # RDS MySQL Multi-AZ
│   ├── monitoring/            # CloudWatch, SNS, Alarmas, Dashboard
│   └── backup/               # AWS Backup Plan
├── scripts/
│   ├── user-data.sh           # Script de inicialización de EC2
│   └── install-cw-agent.sh    # Script de instalación de CW Agent
├── .github/workflows/
│   ├── terraform-plan.yml     # Plan en Pull Requests
│   ├── terraform-apply.yml    # Apply al hacer push a main
│   └── terraform-destroy.yml  # Destrucción manual
└── README.md
```

## Requisitos Previos

### AWS Academy Learner Lab

1. **Credenciales temporales**: Obtén tus credenciales de AWS Academy
   - Access Key ID
   - Secret Access Key
   - Session Token

2. **Bucket S3 para State**: Crear manualmente
   ```bash
   aws s3 mb s3://tu-bucket-terraform-state --region us-east-1
   ```

3. **Tabla DynamoDB para Locking**: Crear manualmente
   ```bash
   aws dynamodb create-table \
     --table-name tu-tabla-locks \
     --attribute-definitions AttributeName=LockID,AttributeType=S \
     --key-schema AttributeName=LockID,KeyType=HASH \
     --billing-mode PAY_PER_REQUEST \
     --region us-east-1
   ```

## Configuración

### 1. Clonar el repositorio

```bash
git clone https://github.com/tu-usuario/tu-repo.git
cd tu-repo
```

### 2. Configurar variables

```bash
cp environments/dev/terraform.tfvars.example environments/dev/terraform.tfvars
```

Editar `terraform.tfvars` con tus valores:

```hcl
aws_region   = "us-east-1"
project_name = "technova"
vpc_cidr     = "10.0.0.0/16"

# AMI personalizada (debes crear una desde una instancia t3.small)
ami_id = "ami-0xxxxxxxxxxxxx"

# Contraseña RDS (mínimo 8 caracteres)
db_password = "TuPassword123!"

# ARN del LabRole de AWS Academy
lab_role_arn = "arn:aws:iam::123456789012:role/LabRole"

# Tu correo para notificaciones SNS
email_sns = "tu@email.com"
```

### 3. Configurar Secrets en GitHub

En tu repositorio de GitHub, ve a **Settings > Secrets and variables > Actions** y agrega:

| Secret | Descripción |
|--------|-------------|
| `AWS_ACCESS_KEY_ID` | Access Key de AWS Academy |
| `AWS_SECRET_ACCESS_KEY` | Secret Key de AWS Academy |
| `AWS_SESSION_TOKEN` | Session Token de AWS Academy |

## Uso

### GitHub Actions

| Trigger | Acción |
|---------|--------|
| Pull Request a `main` | Ejecuta `terraform plan` |
| Push a `main` | Ejecuta `terraform apply` |
| Manual (workflow_dispatch) | `terraform destroy` |

### Ejecución Local

```bash
# Inicializar Terraform
cd environments/dev
terraform init

# Ver plan
terraform plan

# Aplicar cambios
terraform apply

# Destruir recursos
terraform destroy
```

## Componentes Creados

### Networking
- VPC con CIDR 10.0.0.0/16
- 2 subredes públicas (una por AZ)
- 2 subredes privadas App (una por AZ)
- 2 subredes privadas Data (una por AZ)
- Internet Gateway
- 2 NAT Gateways (una por AZ)
- Route Tables asociadas

### Compute
- Launch Template con AMI personalizada
- Auto Scaling Group (Min: 2, Max: 3, Desired: 2)
- Instancias t3.small con Docker y Docker Compose
- CloudWatch Agent instalado

### Load Balancer
- Application Load Balancer público
- Target Group en puerto 80
- Health checks configurados

### Database
- RDS MySQL 8.0, db.t4g.small
- Multi-AZ habilitado
- Storage encriptado (gp3, 50GB)
- Retención de backups: 7 días

### Monitoreo
- SNS Topic para alertas
- Suscripción por email
- Alarmas CloudWatch:
  - CPU ASG > 75%
  - CPU ASG < 20%
  - ALB 5XX errors
  - CPU RDS > 75%
  - RDS connections > 80%
  - ASG instances < 2
- Dashboard con métricas

### Backup
- AWS Backup Plan diario
- Retención: 7 días
- Vault encriptado con KMS

## Notas Importantes

1. **Nunca hacer commit de archivos sensibles**: `terraform.tfvars`, credenciales, archivos `.pem`
2. **State remoto**: Usar S3 + DynamoDB para evitar conflictos
3. **AWS Academy**: Las credenciales expiran, recuerda actualizarlas
4. **AMI**: Debes crear tu propia AMI desde una instancia t3.small con Docker instalado

## Limpieza

Para destruir todos los recursos:

```bash
cd environments/dev
terraform destroy
```

O usar el workflow `terraform-destroy.yml` escribiendo "yes" en el parámetro `confirm_destroy`.

## Autores

- Estudiante: Pablo Contreras
- Curso: Cloud Engineering - Infraestrutura como Código
- Fecha: 2026