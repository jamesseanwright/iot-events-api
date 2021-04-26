resource "aws_iam_role" "lambda_role" {
  name = "${var.function_name}_iam_role"

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
  handler       = "index.handler"
  runtime       = "nodejs14.x"
  role          = aws_iam_role.lambda_role.arn
}
