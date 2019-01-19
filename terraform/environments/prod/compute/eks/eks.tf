variable "project"                      { }
variable "environment"                  { }
variable "region"                       { }
variable "asg_desired_capacity"         { }
variable "asg_max_size"                 { }
variable "asg_min_size"                 { }
variable "instance_type"                { }

provider "aws" {
  region = "${var.region}"
}

terraform {
  required_version = "> 0.7.0"

  backend "s3" {
    bucket = "insight-prod-terraform"
    key    = "compute/eks/eks.tfstate"
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

module "eks" {
  source       = "terraform-aws-modules/eks/aws"
  cluster_name = "${var.project}-${var.environment}-cluster"

  # TODO:  Get this remote state working
  #subnets      = "${data.terraform_remote_state.vpc_state.output.public_subnets}"
  #vpc_id       = "${data.terraform_remote_state.vpc_state.output.vpc_id}"

  subnets       = ["subnet-0d2dcd3a236cd26e0","subnet-037d9bbf5c21001f5"]
  vpc_id        = "vpc-0b669170959a1c289"

  worker_groups = [
    {
      asg_desired_capacity          = "3"                             # Desired worker capacity in the autoscaling group.
      asg_max_size                  = "${var.asg_max_size}"           # Maximum worker capacity in the autoscaling group.
      asg_min_size                  = "${var.asg_min_size}"           # Minimum worker capacity in the autoscaling group.
      instance_type                 = "${var.instance_type}"          # Size of the workers instances.
      spot_price                    = ""                              # Cost of spot instance.
      placement_tenancy             = ""                              # The tenancy of the instance. Valid values are "default" or "dedicated".
      root_volume_size              = "100"                           # root volume size of workers instances.
      root_volume_type              = "gp2"                           # root volume type of workers instances, can be 'standard', 'gp2', or 'io1'
      root_iops                     = "0"                             # The amount of provisioned IOPS. This must be set with a volume_type of "io1".
      key_name                      = "ops"                           # The key name that should be used for the instances in the autoscaling group
      pre_userdata                  = ""                              # userdata to pre-append to the default userdata.
      additional_userdata           = ""                              # userdata to append to the default userdata.
      ebs_optimized                 = true                            # sets whether to use ebs optimization on supported types.
      enable_monitoring             = true                            # Enables/disables detailed monitoring.
      public_ip                     = false                           # Associate a public ip address with a worker
      kubelet_extra_args            = ""                              # This string is passed directly to kubelet if set. Useful for adding labels or taints.
      autoscaling_enabled           = false                           # Sets whether policy and matching tags will be added to allow autoscaling.
      additional_security_group_ids = ""                              # A comma delimited list of additional security group ids to include in worker launch config
      protect_from_scale_in         = false                           # Prevent AWS from scaling in, so that cluster-autoscaler is solely responsible.
      suspended_processes           = ""                              # A comma delimited string of processes to to suspend. i.e. AZRebalance,HealthCheck,ReplaceUnhealthy
      target_group_arns              = ""                             # A comma delimited list of ALB target group ARNs to be associated to the ASG
    }
  ]

  write_kubeconfig = false
  manage_aws_auth = true

  tags = {
    environment = "${var.environment}"
  }
}
