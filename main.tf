terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.37.0"
    }

    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "~> 0.9.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.1.0"
    }
  }

  required_version = "~> 0.15.0"
}

provider "aws" {
  profile = "default"
  region  = var.region
}

provider "mongodbatlas" {
  # The public and private keys are configured via the
  # MONGODB_ATLAS_PUBLIC_KEY and MONGODB_ATLAS_PRIVATE_KEY
  # environment variables respectively
}

provider "random" {}

module "vpc" {
  source = "./tf-modules/vpc"
}

module "atlas" {
  source            = "./tf-modules/atlas"
  region            = var.region
  atlas_org_id      = var.atlas_org_id
  vpc_id            = module.vpc.id
  subnet_ids        = module.vpc.subnet_ids
  security_group_id = module.vpc.security_group_id
}

module "add_event_lambda" {
  source               = "./tf-modules/ecr-lambda"
  repo_name            = "add-event"
  function_name        = "add_event"
  source_arn           = aws_api_gateway_rest_api.api.execution_arn
  subnet_ids           = module.vpc.subnet_ids
  security_group_id    = module.vpc.security_group_id
  db_connection_string = module.atlas.connection_string
  db_username          = module.atlas.username
  db_password          = module.atlas.password
}

module "list_recent_events_lambda" {
  source               = "./tf-modules/ecr-lambda"
  repo_name            = "list-recent-events"
  function_name        = "list_recent_events"
  source_arn           = aws_api_gateway_rest_api.api.execution_arn
  subnet_ids           = module.vpc.subnet_ids
  security_group_id    = module.vpc.security_group_id
  db_connection_string = module.atlas.connection_string
  db_username          = module.atlas.username
  db_password          = module.atlas.password
}

resource "aws_api_gateway_rest_api" "api" {
  name = "iot-events"
}

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.api.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_account" "iot_events" {
  cloudwatch_role_arn = aws_iam_role.cloudwatch.arn
}

resource "aws_iam_role" "cloudwatch" {
  name = "api_gateway_cloudwatch_global"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "cloudwatch" {
  name = "default"
  role = aws_iam_role.cloudwatch.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:PutLogEvents",
                "logs:GetLogEvents",
                "logs:FilterLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_api_gateway_stage" "production" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "production"
}

resource "aws_api_gateway_resource" "events" {
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.api.id
  path_part   = "events"
}

resource "aws_api_gateway_method" "get" {
  resource_id   = aws_api_gateway_resource.events.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  authorization = "NONE" # TODO: API key
  http_method   = "GET"
}

resource "aws_api_gateway_method" "post" {
  resource_id   = aws_api_gateway_resource.events.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  authorization = "NONE" # TODO: API key
  http_method   = "POST"
}

resource "aws_api_gateway_integration" "list_recent_events" {
  resource_id             = aws_api_gateway_resource.events.id
  rest_api_id             = aws_api_gateway_rest_api.api.id
  http_method             = aws_api_gateway_method.get.http_method
  integration_http_method = "POST" # The method with which the lambda invocation endpoint is hit
  type                    = "AWS_PROXY"
  uri                     = module.list_recent_events_lambda.invoke_arn
}

resource "aws_api_gateway_integration" "add_event" {
  resource_id             = aws_api_gateway_resource.events.id
  rest_api_id             = aws_api_gateway_rest_api.api.id
  http_method             = aws_api_gateway_method.post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.add_event_lambda.invoke_arn
}
