terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.49.0"
    }
  }

  required_version = "~> 1.0.0"
}

provider "aws" {
  profile = "default"
  region  = var.region
}

module "vpc" {
  source = "./tf-modules/vpc"
  region = var.region
}

module "atlas" {
  source            = "./tf-modules/atlas"
  region            = var.region
  atlas_org_id      = var.atlas_org_id
  vpc_id            = module.vpc.id
  subnet_ids        = module.vpc.subnet_ids
  security_group_id = module.vpc.atlas_endpoint_security_group_id
}

resource "aws_iam_role" "lambda_role" {
  name = "events_lambda_iam_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Effect = "Allow"
    }]
  })

  inline_policy {
    name = "events_lambda_network_config_role"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Action = [
          "ec2:DescribeNetworkInterfaces",
          "ec2:CreateNetworkInterface",
          "ec2:AttachNetworkInterface",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeInstances"
        ]
        Resource = "*"
        Effect   = "Allow"
      }]
    })
  }
}

module "add_event_lambda" {
  source               = "./tf-modules/ecr-lambda"
  name                 = "add-event"
  source_arn           = module.rest_api.execution_arn
  role_arn             = aws_iam_role.lambda_role.arn
  subnet_ids           = module.vpc.subnet_ids
  security_group_id    = module.vpc.atlas_resource_security_group_id
  db_connection_string = module.atlas.connection_string
  db_username          = module.atlas.username
  db_password          = module.atlas.password
}

module "get_events_lambda" {
  source               = "./tf-modules/ecr-lambda"
  name                 = "get-events"
  source_arn           = module.rest_api.execution_arn
  role_arn             = aws_iam_role.lambda_role.arn
  subnet_ids           = module.vpc.subnet_ids
  security_group_id    = module.vpc.atlas_resource_security_group_id
  db_connection_string = module.atlas.connection_string
  db_username          = module.atlas.username
  db_password          = module.atlas.password
}

module "rest_api" {
  source                       = "./tf-modules/rest-api"
  api_key                      = var.rest_api_key
  get_events_lambda_invoke_arn = module.get_events_lambda.invoke_arn
  add_event_lambda_invoke_arn  = module.add_event_lambda.invoke_arn
}
