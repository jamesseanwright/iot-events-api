resource "aws_iam_role" "lambda_role" {
  name = "${var.function_name}_iam_role"

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
    name = "${var.function_name}_network_config_role"

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
        Effect = "Allow"
      }]
    })
  }
}

resource "aws_ecr_repository" "lambda_repo" {
  name = var.repo_name

  # TODO: these provisioners will only run when the
  # repo is created for the first time. Find a better
  # way to build and push containers as code changes.
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
      MONGODB_USER = var.db_username
      MONGODB_PASSWORD = var.db_password
    }
  }

  vpc_config {
    subnet_ids = var.subnet_ids
    security_group_ids = [var.security_group_id]
  }
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id = "AllowExecutionFromAPIGateway"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal = "apigateway.amazonaws.com"
  source_arn = "${var.source_arn}/*/*/events" # /$stage/$method/events
}
