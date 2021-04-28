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
}

module "atlas" {
  source = "./tf-modules/atlas"
  region = var.region
  atlas_org_id = var.atlas_org_id
  vpc_id = module.vpc.id
  subnet_ids = module.vpc.subnet_ids
  security_group_id = module.vpc.security_group_id
}

module "add_event_lambda" {
  source               = "./tf-modules/ecr-lambda"
  repo_name            = "add-event"
  function_name        = "add_event"
  subnet_ids           = module.vpc.subnet_ids
  security_group_id    = module.vpc.security_group_id
  db_connection_string = module.atlas.connection_string
}

module "list_recent_events_lambda" {
  source               = "./tf-modules/ecr-lambda"
  repo_name            = "list-recent-events"
  function_name        = "list_recent_events"
  subnet_ids           = module.vpc.subnet_ids
  security_group_id    = module.vpc.security_group_id
  db_connection_string = module.atlas.connection_string
}
