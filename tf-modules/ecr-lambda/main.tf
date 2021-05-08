locals {
  function_name = replace(var.name, "-", "_")
}

resource "aws_ecr_repository" "lambda_repo" {
  name = var.name

  # TODO: these provisioners will only run when the
  # repo is created for the first time. Find a better
  # way to build and push containers as code changes.
  provisioner "local-exec" {
    command = "docker build -t ${self.repository_url} --build-arg handler=${var.name} handlers"
  }

  provisioner "local-exec" {
    command = "docker push ${self.repository_url}"
  }
}

resource "aws_lambda_function" "lambda_function" {
  function_name = local.function_name
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.lambda_repo.repository_url}:latest"
  role          = var.role_arn

  environment {
    variables = {
      MONGODB_URI = var.db_connection_string
      MONGODB_USER = var.db_username
      MONGODB_PASSWORD = var.db_password # TODO: place in secrets manager instead
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
