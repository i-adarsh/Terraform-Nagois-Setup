//resource "aws_vpc" "opswork-vpc" {
//  cidr_block       = var.vpc_cidr
//  instance_tenancy = "default"
//
//  tags = {
//    Name = "main"
//  }
//}

resource "aws_iam_role" "role" {
  name = "zqms-opswork-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "opsworks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

resource "aws_iam_policy" "policy" {
  name        = "zqms-opswork-admin-policy"
  description = "My zqms policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
          "cloudwatch:DescribeAlarms",
          "cloudwatch:GetMetricStatistics",
          "ec2:*",
          "ecs:*",
          "elasticloadbalancing:*",
          "iam:GetRolePolicy",
          "iam:ListInstanceProfiles",
          "iam:ListRoles",
          "iam:ListUsers",
          "rds:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
          "iam:PassRole"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]

}
EOF
}

resource "aws_iam_role_policy_attachment" "opswork-role-policy-attach" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy.arn
}


resource "aws_iam_instance_profile" "profile" {
  name = "zms-opswork_profile"
  role = aws_iam_role.role.name
}

resource "aws_opsworks_stack" "main" {
  name                         = var.name
  region                       = "us-east-1"
  service_role_arn             = aws_iam_role.role.arn
  default_instance_profile_arn = aws_iam_instance_profile.profile.arn

  default_availability_zone = "us-east-1a"
//  vpc_id = aws_vpc.opswork-vpc.id
//  default_subnet_id = aws_vpc.opswork-vp
//  custom_cookbooks_source {
//	type = "git"
//	url = "https://xxxx@bitbucket.org/yyyy/cookbooks.git"
//	revision = "master"
//	username = ""
//	password = ""
//  }
}

resource "aws_opsworks_custom_layer" "custlayer" {
  name       = "Zqms layer"
  short_name = "zqms-layer"
  stack_id   = aws_opsworks_stack.main.id
}


resource "aws_opsworks_instance" "my-instance" {
  stack_id = aws_opsworks_stack.main.id

  layer_ids = [
    aws_opsworks_custom_layer.custlayer.id,
  ]

  instance_type = "t2.micro"
  os            = "Amazon Linux 2015.09"
  state         = "stopped"
}

