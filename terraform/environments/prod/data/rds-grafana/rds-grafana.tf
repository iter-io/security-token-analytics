variable "application"                         { }
variable "project"                             { }
variable "environment"                         { }
variable "region"                              { }

variable "allocated_storage"                   { }
variable "allow_major_version_upgrade"         { }
variable "apply_immediately"                   { }
variable "auto_minor_version_upgrade"          { }
variable "backup_retention_period"             { }
variable "backup_window"                       { }
variable "create_db_instance"                  { }
variable "create_db_option_group"              { }
variable "create_db_parameter_group"           { }
variable "create_db_subnet_group"              { }
variable "create_monitoring_role"              { }
variable "deletion_protection"                 { }
variable "engine"                              { }
variable "engine_version"                      { }
variable "family"                              { }
variable "iam_database_authentication_enabled" { }
variable "instance_class"                      { }
variable "iops"                                { }
variable "maintenance_window"                  { }
variable "major_engine_version"                { }
variable "monitoring_interval"                 { }
variable "multi_az"                            { }
variable "port"                                { }
variable "publicly_accessible"                 { }
variable "skip_final_snapshot"                 { }
variable "storage_encrypted"                   { }
variable "storage_type"                        { }


provider "aws" {
  region = "${var.region}"
}

terraform {
  required_version = "> 0.7.0"

  backend "s3" {
    bucket = "insight-prod-terraform"
    key    = "data/rds-grafana/rds-grafana"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "vpc_state" {
  backend = "s3"

  config {
    bucket = "insight-prod-terraform"
    region = "${var.region}"
    key    = "network/vpc/vpc.tfstate"
  }
}

data "aws_ssm_parameter" "username" {
  name = "/prod/rds-grafana/USERNAME"
}

data "aws_ssm_parameter" "password" {
  name = "/prod/rds-grafana/PASSWORD"
}

# TODO:  Lock down to grafana service security group; protected from public access for now though
resource "aws_security_group" "rds" {
  name        = "${var.project}-${var.environment}-${var.application}-rds"
  vpc_id      = "${data.terraform_remote_state.vpc_state.vpc_id}"
  description = "RDS security group"

  tags      {
    Name = "${var.project}-${var.environment}-${var.application}-rds"
    Application = "${var.application}"
    Environment = "${var.environment}"
    Project     = "${var.project}"
  }
  lifecycle { create_before_destroy = true }

  ingress {
    protocol    = "tcp"
    from_port   = "${var.port}"
    to_port     = "${var.port}"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_parameter_group" "default" {
  name        = "${var.environment}-${var.project}-${var.application}"
  family      = "${var.family}"
  description = "RDS cluster parameter group"

  parameter {
    name = "application_name"
    value = "${var.environment}-${var.project}-${var.application}"
  }
}

resource "aws_db_option_group" "default" {
  name                     = "${var.environment}-${var.project}-${var.application}"
  engine_name              = "${var.engine}"
  major_engine_version     = "10"
}

resource "aws_db_subnet_group" "default" {
  name       = "${var.environment}-${var.project}-${var.application}"
  subnet_ids = ["${data.terraform_remote_state.vpc_state.private_subnets}"]

  tags = {
    Application = "${var.application}"
    Environment = "${var.environment}"
    Project     = "${var.project}"
  }
}

#
# https://github.com/terraform-aws-modules/terraform-aws-rds
#
module "rds" {
  source                              = "terraform-aws-modules/rds/aws"

  allocated_storage                   = "${var.allocated_storage}"
  allow_major_version_upgrade         = "${var.allow_major_version_upgrade}"
  apply_immediately                   = "${var.apply_immediately}"
  auto_minor_version_upgrade          = "${var.auto_minor_version_upgrade}"
  availability_zone                   = "${element(data.terraform_remote_state.vpc_state.azs, 0)}"
  backup_retention_period             = "${var.backup_retention_period}"
  backup_window                       = "${var.backup_window}"
  create_db_instance                  = "${var.create_db_instance}"
  create_db_option_group              = "${var.create_db_option_group}"
  create_db_parameter_group           = "${var.create_db_parameter_group}"
  create_db_subnet_group              = "${var.create_db_subnet_group}"
  create_monitoring_role              = "${var.create_monitoring_role}"
  db_subnet_group_name                = "${aws_db_subnet_group.default.name}"
  deletion_protection                 = "${var.deletion_protection}"
  enabled_cloudwatch_logs_exports     = []
  engine                              = "${var.engine}"
  engine_version                      = "${var.engine_version}"
  family                              = "${var.family}"
  final_snapshot_identifier           = "${var.environment}-${var.project}-${var.application}-final"
  iam_database_authentication_enabled = "${var.iam_database_authentication_enabled}"
  identifier                          = "${var.project}-${var.environment}-${var.application}"
  instance_class                      = "${var.instance_class}"
  iops                                = "${var.iops}"
  maintenance_window                  = "${var.maintenance_window}"
  major_engine_version                = "${var.major_engine_version}"
  monitoring_interval                 = "${var.monitoring_interval}"
  monitoring_role_name                = "${var.environment}-rds-${var.application}-monitoring-role"
  multi_az                            = "${var.multi_az}"
  name                                = "${var.environment}_${var.application}"
  option_group_name                   = "${aws_db_option_group.default.name}"
  parameter_group_name                = "${aws_db_parameter_group.default.name}"
  password                            = "${data.aws_ssm_parameter.password.value}"
  port                                = "${var.port}"
  publicly_accessible                 = "${var.publicly_accessible}"
  skip_final_snapshot                 = "${var.skip_final_snapshot}"
  storage_encrypted                   = "${var.storage_encrypted}"
  storage_type                        = "${var.storage_type}"
  subnet_ids                          = "${data.terraform_remote_state.vpc_state.private_subnets}"

  tags = {
    Application = "${var.application}"
    Environment = "${var.environment}"
    Project     = "${var.project}"
  }

  username               = "${data.aws_ssm_parameter.username.value}"
  vpc_security_group_ids = ["${aws_security_group.rds.id}"]
}

output "db_instance_address" {
  value = "${module.rds.this_db_instance_address}"
}

output "db_instance_arn" {
  value = "${module.rds.this_db_instance_arn}"
}

output "tdb_instance_endpoint" {
  value = "${module.rds.this_db_instance_endpoint}"
}

output "db_instance_id" {
  value = "${module.rds.this_db_instance_id}"
}

output "db_instance_name" {
  value = "${module.rds.this_db_instance_name}"
}

output "db_instance_resource_id" {
  value = "${module.rds.this_db_instance_resource_id}"
}
