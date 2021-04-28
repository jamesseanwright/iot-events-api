output "execution_arn" {
  value = aws_api_gateway_rest_api.api.execution_arn
  description = "The execution ARN of the resource, which can be used to invoke other resources"
}