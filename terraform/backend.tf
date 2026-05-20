terraform {
  # Para desarrollo local, usar backend local:
  # Descomenta las siguientes lineos y comenta el backend s3
  # backend "local" {
  #   path = "terraform.tfstate"
  # }

  backend "s3" {
    bucket         = "kbt-technova-terraform-state"
    key            = "technova/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "kbt-technova-terraform-locks"
    encrypt        = true
  }
}