variable "project"                      { }
variable "environment"                  { }
variable "region"                       { }

provider "aws" {
  region = "${var.region}"
}

terraform {
  backend "s3" {
    bucket = "insight-base-terraform"
    key    = "services/airflow/airflow.tfstate"
    region = "us-east-1"
  }
}

module "airflow" {
  source = "../../../../modules/services/airflow"

  project     = "${var.project}"
  environment = "${var.environment}"
  region      = "${var.region}"
}
