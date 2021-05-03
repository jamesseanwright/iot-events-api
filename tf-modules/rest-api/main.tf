resource "aws_api_gateway_rest_api" "api" {
  name = "iot-events"
}

resource "aws_api_gateway_model" "event" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  name = "event"
  description = "Event information sent from a device"
  content_type = "application/json"

  schema = jsonencode({
    "$schema" = "http://json-schema.org/draft-04/schema#"
    type = "object"

    properties = {
      deviceID = {
        type = "string"
        format = "uuid"
      }

      eventType = {
        type = "string"
      }

      date = {
        type = "string"
        format = "date"
      }

      value = {} # can be anything
    }

    required = ["deviceID", "eventType", "date"]
  })
}

resource "aws_api_gateway_request_validator" "get_events" {
  name = "get-events"
  rest_api_id = aws_api_gateway_rest_api.api.id
  validate_request_body = false
  validate_request_parameters = true
}

resource "aws_api_gateway_request_validator" "add_event" {
  name = "add-event"
  rest_api_id = aws_api_gateway_rest_api.api.id
  validate_request_body = true
  validate_request_parameters = false
}

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.api.body))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_method.get,
    aws_api_gateway_method.post,
    aws_api_gateway_integration.get_events,
    aws_api_gateway_integration.add_event
  ]
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
  request_validator_id = aws_api_gateway_request_validator.get_events.id
  request_parameters = {
    "method.request.querystring.deviceID" = true
    "method.request.querystring.date" = true
    "method.request.querystring.eventType" = true
  }
}

resource "aws_api_gateway_method" "post" {
  resource_id      = aws_api_gateway_resource.events.id
  rest_api_id      = aws_api_gateway_rest_api.api.id
  authorization    = "NONE"
  api_key_required = true
  http_method      = "POST"
  request_validator_id = aws_api_gateway_request_validator.add_event.id
  request_models = {
    "application/json" = aws_api_gateway_model.event.name
  }
}

resource "aws_api_gateway_integration" "get_events" {
  resource_id             = aws_api_gateway_resource.events.id
  rest_api_id             = aws_api_gateway_rest_api.api.id
  http_method             = aws_api_gateway_method.get.http_method
  integration_http_method = "POST" # The method with which the lambda invocation endpoint is hit
  type                    = "AWS_PROXY"
  uri                     = var.get_events_lambda_invoke_arn
}

resource "aws_api_gateway_integration" "add_event" {
  resource_id             = aws_api_gateway_resource.events.id
  rest_api_id             = aws_api_gateway_rest_api.api.id
  http_method             = aws_api_gateway_method.post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.add_event_lambda_invoke_arn
}
