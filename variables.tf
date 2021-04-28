variable "region" {
  description = "The AWS region to which the lambdas and AWS-backed Atlas cluster are deployed"
  type        = string
}

variable "atlas_org_id" {
  description = "The ID of your MongoDB Atlas organisation"
  type        = string
}

variable "api_key" {
  description = "The API key with which the REST API must be called"
  type        = string
}
