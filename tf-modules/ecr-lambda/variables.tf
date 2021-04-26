variable "repo_name" {
  description = "Name of the AWS ECR repo, which should match the corresponding folder name under the handlers directory"
  type = string
}

variable "function_name" {
  description = "Name of the AWS Lambda function"
  type = string
}
