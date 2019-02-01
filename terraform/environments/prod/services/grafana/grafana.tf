variable "application"  { }
variable "environment"  { }
variable "project"      { }
variable "region"       { }

provider "aws" {
  region = "${var.region}"
}

terraform {
  backend "s3" {
    bucket = "insight-prod-terraform"
    key    = "services/grafana/grafana.tfstate"
    region = "us-east-1"
  }
}

resource "aws_iam_user" "default" {
  name = "${var.environment}-${var.project}-${var.application}"
}

resource "aws_iam_access_key" "default" {
  user = "${aws_iam_user.default.name}"
}

resource "aws_iam_user_policy" "default_policy" {
  name = "${var.environment}-${var.project}-${var.application}-policy-default"
  user = "${aws_iam_user.default.name}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "cloudwatch:*",
                "logs:*"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }
    ]
}
EOF
}


output "iam_user_arn" {
  value = "${aws_iam_user.default.arn}"
}

output "iam_user_name" {
  value = "${aws_iam_user.default.name}"
}

output "aws_iam_access_key_id" {
  value = "${aws_iam_access_key.default.id}"
}

output "aws_iam_access_key_secret" {
  value = "${aws_iam_access_key.default.secret}"
}

