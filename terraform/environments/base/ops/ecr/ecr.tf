#--------------------------------------------------------------
# Shared "base" ECR components (repositories for docker images)
#--------------------------------------------------------------

variable "region" {}

provider "aws" {
  region = "${var.region}"
}

terraform {
  backend "s3" {
    bucket = "insight-base-terraform"
    key    = "ops/ecr/ecr.tfstate"
    region = "us-east-1"
  }
}

# We are creating ECR as separate resources to be able to remove
# any ECR at any point, using terraform. With ECR passed as list
# it is impossible.

resource "aws_ecr_repository" "security_token_analytics" {
  name = "security-token-analytics"
}
