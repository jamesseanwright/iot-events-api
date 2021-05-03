output "execution_arn" {
  value = aws_api_gateway_rest_api.api.execution_arn
  description = "The execution ARN of the resource, which can be used to invoke other resources"
}

output "url" {
  value = "${aws_api_gateway_stage.production.invoke_url}${aws_api_gateway_resource.events.path}"
  description = "The REST API URL, including the events endpoint, for the deployed service"
}
