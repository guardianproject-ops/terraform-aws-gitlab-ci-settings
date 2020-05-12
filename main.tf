terraform {
  required_version = ">= 0.12.0"
  required_providers {
    aws     = "~> 2.0"
    archive = "~> 1.3.0"
    gitlab  = "~> 2.5"
  }
}


module "label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.16.0"
  namespace  = var.namespace
  stage      = var.stage
  name       = var.name
  delimiter  = var.delimiter
  attributes = var.attributes
  tags       = var.tags
  additional_tag_map = {
    CI = "true"
  }
}

module "public_subnet_label" {
  source    = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.16.0"
  namespace = var.namespace
  name      = var.name
  stage     = var.stage
  delimiter = var.delimiter
  tags      = var.tags
  additional_tag_map = {
    CI         = "true"
    Visibility = "Public"
  }
}

module "instance_cleanp" {
  source          = "git::https://gitlab.com/guardianproject-ops/terraform-aws-lambda-instance-cleanup.git?ref=tags/0.1.0"
  namespace       = var.namespace
  name            = var.name
  stage           = var.stage
  delimiter       = var.delimiter
  attributes      = ["instance-cleanup"]
  tags            = var.tags
  regions         = [var.region]
  schedule        = "rate(10 minutes)"
  max_age_minutes = 5
  limit_tags = {
    "Namespace" = [var.namespace],
    "Stage"     = [var.stage],
    "CI"        = ["true"],
  }
}

locals {
  username = "${var.name}-${var.stage}-${var.namespace}"
}

data "aws_caller_identity" "current" {}

resource "aws_vpc" "ci_vpc" {
  cidr_block = var.vpc_cidr_block
  tags       = module.label.tags
}

resource "aws_internet_gateway" "ci_gateway" {
  vpc_id = aws_vpc.ci_vpc.id
  tags   = module.label.tags
}

resource "aws_subnet" "ci_subnet" {
  vpc_id            = aws_vpc.ci_vpc.id
  cidr_block        = var.vpc_subnet_cidr_block
  availability_zone = var.vpc_subnet_az
  tags              = merge(module.public_subnet_label.tags, map("Name", format("%s%s%s", module.public_subnet_label.id, var.delimiter, "one")))
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.ci_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ci_gateway.id
  }
  tags = merge(module.public_subnet_label.tags, map("Name", module.public_subnet_label.id))
}

resource "aws_route_table_association" "public_association_one" {
  subnet_id      = aws_subnet.ci_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

data "aws_iam_policy_document" "gitlab_ci" {
  version = "2012-10-17"
  statement {
    actions = [
      "ec2:Describe*",
      "ec2:CreateSecurityGroup",
      "ec2:CreateKeyPair",
      "ec2:DeleteKeyPair"
    ]
    resources = ["*"]
    effect    = "Allow"
  }
  statement {
    # Allow actions when the resource is tagged.
    actions = [
      "ec2:StartInstances",
      "ec2:StopInstances",
      "ec2:RebootInstances",
      "ec2:TerminateInstances",
      "ec2:CreateTags",
      "ec2:DeleteTags",
      "ec2:AttachVolume",
      "ec2:DetachVolume",
      "ec2:DeleteVolume",
      "ec2:DeleteSnapshot"
    ]
    condition {
      test     = "StringEquals"
      variable = "ec2:ResourceTag/Namespace"
      values   = [var.namespace]
    }
    condition {
      test     = "StringEquals"
      variable = "ec2:ResourceTag/Stage"
      values   = [var.stage]
    }
    condition {
      test     = "StringEquals"
      variable = "ec2:ResourceTag/CI"
      values   = ["true"]
    }
    resources = [
      "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:instance/*"
    ]
    effect = "Allow"
  }

  statement {
    # Allow creating tags only when creating a volume, launching an instance, or creating a snapshot.
    actions = [
      "ec2:CreateTags"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "ec2:CreateAction"
      values = [
        "CreateVolume",
        "RunInstances",
        "CreateSnapshot"
      ]
    }
  }
  statement {
    # Allow creating tags only when creating security group in our vpc
    actions = [
      "ec2:CreateTags"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:Type"
      values = [
        "security-group"
      ]
    }
    condition {
      test     = "ArnEquals"
      variable = "ec2:Vpc"
      values   = ["arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:vpc/${aws_vpc.ci_vpc.id}"]
    }
  }

  statement {
    # Allow launching an instance, but only if the tag is set and it is in the CI subnet
    actions = [
      "ec2:RunInstances"
    ]
    resources = [
      "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:instance/*",
      "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:volume/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/CI"
      values   = ["true"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/Namespace"
      values   = [var.namespace]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/Stage"
      values   = [var.stage]
    }
    effect = "Allow"
  }

  statement {
    # Allow launching an instance on resources we can't restrict with tags
    actions = [
      "ec2:RunInstances"
    ]
    resources = [
      "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:security-group/*",
      "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:network-interface/*",
      "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:key-pair/*",
      "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:subnet/${aws_subnet.ci_subnet.id}",
      "arn:aws:ec2:*:*:image/ami-*",
    ]
    effect = "Allow"
  }

  statement {
    actions = [
      "ec2:DeleteSecurityGroup",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:AuthorizeSecurityGroupEgress",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupEgress"
    ]
    resources = [
      "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:security-group/*"
    ]
    condition {
      test     = "ArnEquals"
      variable = "ec2:Vpc"
      values   = ["arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:vpc/${aws_vpc.ci_vpc.id}"]
    }
    effect = "Allow"
  }
}

resource "aws_iam_user" "gitlab_ci" {
  name = local.username
}

resource "aws_iam_user_policy" "gitlab_ci" {
  name   = aws_iam_user.gitlab_ci.name
  user   = aws_iam_user.gitlab_ci.name
  policy = data.aws_iam_policy_document.gitlab_ci.json
}

resource "aws_iam_access_key" "gitlab_ci" {
  user = aws_iam_user.gitlab_ci.name
}

resource "gitlab_project_variable" "aws_region" {
  count   = length(var.gitlab_project_ids)
  project = var.gitlab_project_ids[count.index]
  key     = "AWS_REGION"
  value   = var.region
}

resource "gitlab_project_variable" "aws_access_key" {
  count   = length(var.gitlab_project_ids)
  project = var.gitlab_project_ids[count.index]
  key     = "AWS_ACCESS_KEY"
  masked  = true
  value   = aws_iam_access_key.gitlab_ci.id
}

resource "gitlab_project_variable" "aws_secret_access_key" {
  count   = length(var.gitlab_project_ids)
  project = var.gitlab_project_ids[count.index]
  key     = "AWS_SECRET_ACCESS_KEY"
  masked  = true
  value   = aws_iam_access_key.gitlab_ci.secret
}

resource "gitlab_project_variable" "aws_subnet_id" {
  count   = length(var.gitlab_project_ids)
  project = var.gitlab_project_ids[count.index]
  key     = "AWS_SUBNET_ID"
  value   = aws_subnet.ci_subnet.id
}

resource "gitlab_project_variable" "aws_vpc_id" {
  count   = length(var.gitlab_project_ids)
  project = var.gitlab_project_ids[count.index]
  key     = "AWS_VPC_ID"
  value   = aws_vpc.ci_vpc.id
}

resource "gitlab_pipeline_schedule" "example" {
  count         = length(var.gitlab_docker_image_project_ids)
  project       = var.gitlab_docker_image_project_ids[count.index]
  description   = "Daily Rebuild"
  ref           = "master"
  cron          = var.gitlab_schedule_daily_rebuild_cron
  cron_timezone = "UTC"
}
