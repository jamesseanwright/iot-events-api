variable "api_key" {
  description = "The API key with which the REST endpoints must be called"
  type        = string
}

variable "list_recent_events_lambda_invoke_arn" {
  description = "The invoke ARN that the respective API Gateway integration will use to call the list recent events lambda"
  type        = string
}

variable "add_event_lambda_invoke_arn" {
  description = "The invoke ARN that the respective API Gateway integration will use to call the list recent events lambda"
  type        = string
}
