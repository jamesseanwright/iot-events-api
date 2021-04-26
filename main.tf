terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.37.0"
    }
  }

  required_version = "~> 0.15.0"
}

provider "aws" {
  profile = "default"
  region  = "eu-west-1"
}

module "add_event_lambda" {
  source = "./tf-modules/ecr-lambda"
  repo_name = "add-event"
  function_name = "add_event"
}

module "list_recent_events_lambda" {
  source = "./tf-modules/ecr-lambda"
  repo_name = "list-recent-events"
  function_name = "list_recent_events"
}
