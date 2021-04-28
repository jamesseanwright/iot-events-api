variable "repo_name" {
  description = "Name of the AWS ECR repo, which should match the corresponding folder name under the handlers directory"
  type = string
}

variable "function_name" {
  description = "Name of the AWS Lambda function"
  type = string
}

variable "source_arn" {
  description = "The execution ARN of the resource that will invoke the lambda"
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

variable "db_connection_string" {
  description = "The MongoDB connection string the lambda will use to connect to Atlas"
  type = string
}

variable "db_username" {
  description = "The username of the account with which to access the database"
  type = string
}

variable "db_password" {
  description = "The password of the account with which to access the database"
  type = string
}

