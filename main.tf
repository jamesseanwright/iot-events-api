terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.37.0"
    }
  }

  required_version = "~> 0.15.0"
}

provider "aws" {
  profile = "default"
  region  = "eu-west-1"
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_lambda_function" "hello_world" {
  filename         = "deployment/hello-world.zip"
  function_name    = "hello_world"
  handler          = "index.handler"
  runtime          = "nodejs14.x"
  role             = aws_iam_role.iam_for_lambda.arn
  source_code_hash = filebase64sha256("deployment/hello-world.zip")
}
