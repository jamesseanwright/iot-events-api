variable "region" {
  description = "The AWS region to which the lambdas and AWS-backed Atlas cluster are deployed"
  type        = string
}

variable "atlas_org_id" {
  description = "The ID of your MongoDB Atlas organisation"
  type        = string
}

variable "vpc_id" {
  description = "The ID of our IoT events VPC"
  type        = string
}

variable "subnet_ids" {
  description = "The IDs of our IoT events subnets"
  type        = list(string)
}

variable "security_group_id" {
  description = "The ID of the Atlas endpoint security group"
  type        = string
}
