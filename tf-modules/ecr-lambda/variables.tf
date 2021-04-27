variable "repo_name" {
  description = "Name of the AWS ECR repo, which should match the corresponding folder name under the handlers directory"
  type = string
}

variable "function_name" {
  description = "Name of the AWS Lambda function"
  type = string
}

variable "subnet_ids" {
  description = "The VPC subnet IDs to which the lambda should attach"
  type = list(string)
}

variable "security_group_id" {
  description = "The VPC default security group ID for the lambda"
  type = string
}
