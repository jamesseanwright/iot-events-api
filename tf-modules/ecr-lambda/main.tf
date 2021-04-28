resource "aws_iam_role" "lambda_role" {
  name = "${var.function_name}_iam_role"

# TODO: use json() helper or policy resource
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

  inline_policy {
    name = "${var.function_name}_network_config_role"

    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:DescribeNetworkInterfaces",
        "ec2:CreateNetworkInterface",
        "ec2:AttachNetworkInterface",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeInstances"
      ],
      "Resource": "*",
      "Effect": "Allow"
    }
  ]
}
EOF
  }
}

resource "aws_ecr_repository" "lambda_repo" {
  name = var.repo_name

  provisioner "local-exec" {
    command = "docker build -t ${self.repository_url} handlers/${var.repo_name}"
  }

  provisioner "local-exec" {
    command = "docker push ${self.repository_url}"
  }
}

resource "aws_lambda_function" "lambda_function" {
  function_name = var.function_name
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.lambda_repo.repository_url}:latest"
  role          = aws_iam_role.lambda_role.arn

  environment {
    variables = {
      MONGODB_URI = var.db_connection_string
    }
  }

  vpc_config {
    subnet_ids = var.subnet_ids
    security_group_ids = [var.security_group_id]
  }
}
