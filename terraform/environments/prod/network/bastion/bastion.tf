variable "project"              { }
variable "environment"          { }
variable "region"               { }
variable "allowed_cidr_blocks"  { }
variable "ami"                  { }
variable "instance_type"        { }
variable "key_name"             { }
variable "name"                 { }
variable "ssh_user"             { }

provider "aws" {
  region = "${var.region}"
}

terraform {
  required_version = "> 0.7.0"

  backend "s3" {
    bucket = "insight-prod-terraform"
    key    = "network/bastion/bastion.tfstate"
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


resource "aws_security_group" "bastion" {
  name        = "${var.project}-${var.environment}-bastion-sg"
  vpc_id      = "${data.terraform_remote_state.vpc_state.vpc_id}"
  description = "Bastion security group"

  tags      { Name = "${var.project}-${var.environment}-bastion" }
  lifecycle { create_before_destroy = true }

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "bastion" {
  source              = "github.com/cloudposse/terraform-aws-ec2-bastion-server"
  allowed_cidr_blocks = ["${var.allowed_cidr_blocks}"]
  ami                 = "${var.ami}"
  instance_type       = "${var.instance_type}"
  key_name            = "${var.key_name}"
  name                = "${var.name}"
  namespace           = "${var.project}"
  security_groups     = ["${aws_security_group.bastion.id}"]
  ssh_user            = "${var.ssh_user}"
  stage               = "${var.environment}"
  subnets             = "${data.terraform_remote_state.vpc_state.public_subnets}"
  vpc_id              = "${data.terraform_remote_state.vpc_state.vpc_id}"
}

output "security_group_id" {
  value = "${module.bastion.security_group_id}"
}
