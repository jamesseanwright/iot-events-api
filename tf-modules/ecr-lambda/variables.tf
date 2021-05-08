variable "name" {
  description = "Hyphenated name of the function, from which the ECR repo name and Lambda name will be derived"
  type = string
}

variable "source_arn" {
  description = "The execution ARN of the resource that will invoke the lambda"
  type = string
}

variable "role_arn" {
  description = "The ARN of the IAM role that the lambda will assume"
  type = string
}

variable "subnet_ids" {
  description = "The VPC subnet IDs to which the lambda should attach"
  type = list(string)
}

variable "security_group_id" {
  description = "The ID of the resource security group"
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

