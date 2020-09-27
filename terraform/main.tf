provider "aws" {
  region = "us-east-1"
}

terraform {
  required_providers {
    aws = "~>2.70"
  }
}

module "ssm_orchestration" {
  source = "./ssm-orchestration"
}

module "ssm_powershell" {
  source = "./ssm-powershell"
}

module "ec2" {
  source = "./ec2_instance"
}

module "honeycomb_cloudwatch_integration" {
  source = "./honeycomb_cloudwatch_integration"

  honeycomb_write_key = var.honeycomb_write_key
  honeycomb_dataset_name = var.honeycomb_dataset_name
}