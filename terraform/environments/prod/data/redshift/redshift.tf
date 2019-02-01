variable "project"                              { }
variable "environment"                          { }
variable "region"                               { }
variable "allow_version_upgrade"                { }
variable "automated_snapshot_retention_period"  { }
variable "cluster_node_type"                    { }
variable "cluster_number_of_nodes"              { }
variable "cluster_parameter_group"              { }
variable "cluster_port"                         { }
variable "cluster_version"                      { }
variable "enable_logging"                       { }
variable "encrypted"                            { }
variable "enhanced_vpc_routing"                 { }
variable "logging_bucket_name"                  { }
variable "preferred_maintenance_window"         { }
variable "publicly_accessible"                  { }
variable "skip_final_snapshot"                  { }
variable "wlm_json_configuration"               { }

provider "aws" {
  region = "${var.region}"
}

terraform {
  required_version = "> 0.7.0"

  backend "s3" {
    bucket = "insight-prod-terraform"
    key    = "data/redshift/redshift.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "vpc_state" {
  backend = "s3"

  config {
    bucket = "insight-prod-terraform"
    region = "${var.region}"
    key = "network/vpc/vpc.tfstate"
  }
}

data "terraform_remote_state" "airflow_state" {
  backend = "s3"

  config {
    bucket = "insight-prod-terraform"
    region = "${var.region}"
    key = "services/airflow/airflow.tfstate"
  }
}

data "aws_ssm_parameter" "cluster_master_username" {
  name  = "/prod/redshift/CLUSTER_MASTER_USERNAME"
}


data "aws_ssm_parameter" "cluster_master_password" {
  name  = "/prod/redshift/CLUSTER_MASTER_PASSWORD"
}

#
#  IAM role that allows our Redshift cluster to load data from S3.
#
resource "aws_iam_service_linked_role" "redshift_service_role" {
  aws_service_name = "redshift.amazonaws.com"
}

resource "aws_iam_policy" "s3_read_write_policy" {
  name = "${var.project}-${var.environment}-s3-policy-airflow-output"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Effect": "Allow",
          "Action": [
              "s3:Get*",
              "s3:List*",
              "s3:Put*"
          ],
          "Resource": "${data.terraform_remote_state.airflow_state.s3_bucket_arn_ethereum_etl_output}/*"
      }
  ]
}
  EOF
}

resource "aws_iam_policy_attachment" "redshift_role_s3_policy_attachment" {
  name       = "${var.project}-${var.environment}-redshift-role-s3-policy-attachment"
  roles      = ["${aws_iam_service_linked_role.redshift_service_role.name}"]
  policy_arn = "${aws_iam_policy.s3_read_write_policy.arn}"

  depends_on = [
    "aws_iam_service_linked_role.redshift_service_role",
    "aws_iam_policy.s3_read_write_policy"
  ]
}

resource "aws_security_group" "redshift" {
  name        = "${var.project}-${var.environment}-redshift"
  vpc_id      = "${data.terraform_remote_state.vpc_state.vpc_id}"
  description = "Redshift security group"

  tags      { Name = "${var.project}-${var.environment}-redshift" }
  lifecycle { create_before_destroy = true }

  ingress {
    protocol    = "tcp"
    from_port   = 5439
    to_port     = 5439
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_s3_bucket" "redshift_tables" {
  bucket = "${var.project}-${var.environment}-redshift-tables"
}

#
# https://github.com/terraform-aws-modules/terraform-aws-redshift
#
module "redshift" {
  source                              = "github.com/terraform-aws-modules/terraform-aws-redshift"
  allow_version_upgrade               = "${var.allow_version_upgrade}"
  automated_snapshot_retention_period = "${var.automated_snapshot_retention_period}"
  cluster_database_name               = "${var.environment}_${var.project}"
  cluster_iam_roles                   = ["${aws_iam_service_linked_role.redshift_service_role.arn}"]
  cluster_identifier                  = "${var.project}-${var.environment}-cluster"
  cluster_master_password             = "${data.aws_ssm_parameter.cluster_master_password.value}"
  cluster_master_username             = "${data.aws_ssm_parameter.cluster_master_username.value}"
  cluster_node_type                   = "${var.cluster_node_type}"
  cluster_number_of_nodes             = "${var.cluster_number_of_nodes}"
  cluster_parameter_group             = "${var.cluster_parameter_group}"
  cluster_port                        = "${var.cluster_port}"
  cluster_version                     = "${var.cluster_version}"
  enable_logging                      = "${var.enable_logging}"
  encrypted                           = "${var.encrypted}"
  enhanced_vpc_routing                = "${var.enhanced_vpc_routing}"
  final_snapshot_identifier           = "${var.environment}-${var.project}-final"
  logging_bucket_name                 = "${var.logging_bucket_name}"
  parameter_group_name                = ""
  preferred_maintenance_window        = "${var.preferred_maintenance_window}"
  publicly_accessible                 = "${var.publicly_accessible}"
  redshift_subnet_group_name          = ""
  skip_final_snapshot                 = "${var.skip_final_snapshot}"
  subnets                             = "${data.terraform_remote_state.vpc_state.public_subnets}"
  vpc_security_group_ids              = ["${aws_security_group.redshift.id}"]
  wlm_json_configuration              = "${var.wlm_json_configuration}"
}

output "s3_bucket_arn_redshift_tables" {
  value = "${aws_s3_bucket.redshift_tables.arn}"
}
