resource "aws_api_gateway_rest_api" "api" {
  name = "iot-events"
}

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.api.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_account" "iot_events" {}

resource "aws_api_gateway_stage" "production" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "production"
}

resource "aws_api_gateway_usage_plan" "usage_plan" {
  name = "usage-plan"

  api_stages {
    api_id = aws_api_gateway_rest_api.api.id
    stage  = aws_api_gateway_stage.production.stage_name
  }
}

resource "aws_api_gateway_api_key" "key" {
  name  = "api-key"
  value = var.api_key
}

resource "aws_api_gateway_usage_plan_key" "plan_key" {
  key_id        = aws_api_gateway_api_key.key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.usage_plan.id
}

resource "aws_api_gateway_resource" "events" {
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.api.id
  path_part   = "events"
}

resource "aws_api_gateway_method" "get" {
  resource_id      = aws_api_gateway_resource.events.id
  rest_api_id      = aws_api_gateway_rest_api.api.id
  authorization    = "NONE"
  api_key_required = true
  http_method      = "GET"
}

resource "aws_api_gateway_method" "post" {
  resource_id      = aws_api_gateway_resource.events.id
  rest_api_id      = aws_api_gateway_rest_api.api.id
  authorization    = "NONE"
  api_key_required = true
  http_method      = "POST"
}

resource "aws_api_gateway_integration" "list_recent_events" {
  resource_id             = aws_api_gateway_resource.events.id
  rest_api_id             = aws_api_gateway_rest_api.api.id
  http_method             = aws_api_gateway_method.get.http_method
  integration_http_method = "POST" # The method with which the lambda invocation endpoint is hit
  type                    = "AWS_PROXY"
  uri                     = var.list_recent_events_lambda_invoke_arn
}

resource "aws_api_gateway_integration" "add_event" {
  resource_id             = aws_api_gateway_resource.events.id
  rest_api_id             = aws_api_gateway_rest_api.api.id
  http_method             = aws_api_gateway_method.post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.add_event_lambda_invoke_arn
}
