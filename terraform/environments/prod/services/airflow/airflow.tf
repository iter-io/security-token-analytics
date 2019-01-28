variable "project"                      { }
variable "environment"                  { }
variable "region"                       { }

provider "aws" {
  region = "${var.region}"
}

terraform {
  backend "s3" {
    bucket = "insight-prod-terraform"
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


output "s3_bucket_arn_ethereum_etl_output" {
  value = "${module.airflow.s3_bucket_arn_ethereum_etl_output}"
}

output "s3_bucket_arn_airflow_logs" {
  value = "${module.airflow.s3_bucket_arn_airflow_logs}"
}
