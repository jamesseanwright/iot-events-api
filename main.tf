terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.37.0"
    }

    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "~> 0.9.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.1.0"
    }
  }

  required_version = "~> 0.15.0"
}

provider "aws" {
  profile = "default"
  region  = var.region
}

provider "mongodbatlas" {
  # The public and private keys are configured via the
  # MONGODB_ATLAS_PUBLIC_KEY and MONGODB_ATLAS_PRIVATE_KEY
  # environment variables respectively
}

provider "random" {}

module "vpc" {
  source = "./tf-modules/vpc"
  region = var.region
}

module "atlas" {
  source            = "./tf-modules/atlas"
  region            = var.region
  atlas_org_id      = var.atlas_org_id
  vpc_id            = module.vpc.id
  subnet_ids        = module.vpc.subnet_ids
  security_group_id = module.vpc.security_group_id
}

module "add_event_lambda" {
  source               = "./tf-modules/ecr-lambda"
  name                 = "add-event"
  source_arn           = module.rest_api.execution_arn
  subnet_ids           = module.vpc.subnet_ids
  security_group_id    = module.vpc.security_group_id
  db_connection_string = module.atlas.connection_string
  db_username          = module.atlas.username
  db_password          = module.atlas.password
}

module "get_events_lambda" {
  source               = "./tf-modules/ecr-lambda"
  name                 = "get-events"
  source_arn           = module.rest_api.execution_arn
  subnet_ids           = module.vpc.subnet_ids
  security_group_id    = module.vpc.security_group_id
  db_connection_string = module.atlas.connection_string
  db_username          = module.atlas.username
  db_password          = module.atlas.password
}

module "rest_api" {
  source                       = "./tf-modules/rest-api"
  api_key                      = var.api_key
  get_events_lambda_invoke_arn = module.get_events_lambda.invoke_arn
  add_event_lambda_invoke_arn  = module.add_event_lambda.invoke_arn
}
