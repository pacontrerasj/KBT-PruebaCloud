terraform {
  backend "s3" {
    bucket         = "kbt-technova-terraform-state"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}