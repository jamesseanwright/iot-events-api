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

resource "aws_ecr_repository" "hello_world_lambda_repo" {
  name = "hello-world"

  provisioner "local-exec" {
    command = "docker build -t ${self.repository_url} handlers/hello-world"
  }

  provisioner "local-exec" {
    command = "docker push ${self.repository_url}"
  }
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
  function_name = "hello_world"
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.hello_world_lambda_repo.repository_url}:latest"
  handler       = "index.handler"
  runtime       = "nodejs14.x"
  role          = aws_iam_role.iam_for_lambda.arn
}
