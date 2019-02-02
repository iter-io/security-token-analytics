#--------------------------------------------------------------
# Networking components for the "prod" environment
#--------------------------------------------------------------

variable "project"                      { }
variable "environment"                  { }
variable "region"                       { }
variable "cidr"                         { }
variable "azs"                          { }
variable "public_subnets"               { }
variable "private_subnets"              { }
variable "create_database_subnet_group" { }
variable "enable_nat_gateway"           { }
variable "enable_vpn_gateway"           { }
variable "enable_dns_hostnames"         { }
variable "enable_dns_support"           { }

provider "aws" {
  region = "${var.region}"
}

terraform {
  required_version = "> 0.7.0"

  backend "s3" {
    bucket = "insight-prod-terraform"
    key    = "network/vpc/vpc.tfstate"
    region = "us-east-1"
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.project}-${var.environment}"
  cidr = "${var.cidr}"
  azs             = ["${split(",", var.azs)}"]
  private_subnets = ["${split(",", var.private_subnets)}"]
  public_subnets  = ["${split(",", var.public_subnets)}"]

  enable_nat_gateway = "${var.enable_nat_gateway}"
  enable_vpn_gateway = "${var.enable_vpn_gateway}"
  enable_dns_hostnames = "${var.enable_dns_hostnames}"
  enable_dns_support = "${var.enable_dns_support}"

  create_database_subnet_group = true

  tags = {
    terraform = "true"
    environment = "prod"
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "true"
    "kubernetes.io/cluster/insight-prod-cluster" = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "true"
  }

}

output "azs" {
  value = "${module.vpc.azs}"
}

output "database_subnet_group" {
  value = "${module.vpc.database_subnet_group}"
}

output "private_subnets" {
  value = "${module.vpc.private_subnets}"
}

output "public_subnets" {
  value = "${module.vpc.public_subnets}"
}

output "vpc_id" {
  value = "${module.vpc.vpc_id}"
}
