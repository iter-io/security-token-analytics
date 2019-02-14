variable "application"   { }
variable "environment"   { }
variable "project"       { }
variable "region"        { }

variable "airflow_core_remote_base_log_folder" { }
variable "airflow_core_encrypt_s3_logs"        { }
variable "airflow_webserver_rbac"              { }

provider "aws" {
  region = "${var.region}"
}

provider "kubernetes" {
  config_context = "arn:aws:eks:us-east-1:772681551441:cluster/insight-prod-cluster"
}

terraform {
  backend "s3" {
    bucket = "insight-prod-terraform"
    key    = "services/airflow/airflow.tfstate"
    region = "us-east-1"
  }
}

data "aws_ssm_parameter" "airflow_conn_aws_default" {
  name  = "/prod/airflow/AIRFLOW_CONN_AWS_DEFAULT"
}

data "aws_ssm_parameter" "airflow_conn_redshift" {
  name  = "/prod/airflow/AIRFLOW_CONN_REDSHIFT"
}

data "aws_ssm_parameter" "airflow_core_fernet_key" {
  name  = "/prod/airflow/AIRFLOW__CORE__FERNET_KEY"
}

data "aws_ssm_parameter" "airflow_core_remote_log_conn_id" {
  name  = "/prod/airflow/AIRFLOW__CORE__REMOTE_LOG_CONN_ID"
}

data "aws_ssm_parameter" "airflow_core_sql_alchemy_conn" {
  name  = "/prod/airflow/AIRFLOW__CORE__SQL_ALCHEMY_CONN"
}

data "aws_ssm_parameter" "aws_access_key_id" {
  name  = "/prod/airflow/AWS_ACCESS_KEY_ID"
}

data "aws_ssm_parameter" "aws_secret_access_key" {
  name  = "/prod/airflow/AWS_SECRET_ACCESS_KEY"
}

module "airflow" {
  source = "../../../../modules/services/airflow"

  application = "${var.application}"
  environment = "${var.environment}"
  project     = "${var.project}"
  region      = "${var.region}"

  airflow_conn_aws_default            = "${data.aws_ssm_parameter.airflow_conn_aws_default.value}"
  airflow_conn_redshift               = "${data.aws_ssm_parameter.airflow_conn_redshift.value}"
  airflow_core_encrypt_s3_logs        = "${var.airflow_core_encrypt_s3_logs}"
  airflow_core_fernet_key             = "${data.aws_ssm_parameter.airflow_core_fernet_key.value}"
  airflow_core_remote_base_log_folder = "${var.airflow_core_remote_base_log_folder}"
  airflow_core_remote_log_conn_id     = "${data.aws_ssm_parameter.airflow_core_remote_log_conn_id.value}"
  airflow_core_sql_alchemy_conn       = "${data.aws_ssm_parameter.airflow_core_sql_alchemy_conn.value}"
  airflow_webserver_rbac              = "${var.airflow_webserver_rbac}"
  aws_access_key_id                   = "${data.aws_ssm_parameter.aws_access_key_id.value}"
  aws_secret_access_key               = "${data.aws_ssm_parameter.aws_secret_access_key.value}"
}


output "s3_bucket_arn_ethereum_etl_output" {
  value = "${module.airflow.s3_bucket_arn_ethereum_etl_output}"
}

output "s3_bucket_arn_airflow_logs" {
  value = "${module.airflow.s3_bucket_arn_airflow_logs}"
}
