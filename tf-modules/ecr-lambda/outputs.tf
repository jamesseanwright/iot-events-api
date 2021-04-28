output "invoke_arn" {
  value = aws_lambda_function.lambda_function.invoke_arn
  description = "The invocation ARN that can be called by API Gateway"
}
