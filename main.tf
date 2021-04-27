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

module "vpc" {
  source = "./tf-modules/vpc"
}

module "add_event_lambda" {
  source            = "./tf-modules/ecr-lambda"
  repo_name         = "add-event"
  function_name     = "add_event"
  subnet_ids        = module.vpc.subnet_ids
  security_group_id = module.vpc.security_group_id
}

module "list_recent_events_lambda" {
  source            = "./tf-modules/ecr-lambda"
  repo_name         = "list-recent-events"
  function_name     = "list_recent_events"
  subnet_ids        = module.vpc.subnet_ids
  security_group_id = module.vpc.security_group_id
}

resource "mongodbatlas_project" "iot_events" {
  name   = "iot-events"
  org_id = var.atlas_org_id
}

resource "mongodbatlas_cluster" "events" {
  project_id                  = mongodbatlas_project.iot_events.id
  name                        = "events"
  provider_name               = "AWS"
  provider_region_name        = upper(replace(var.region, "-", "_")) # e.g. eu-west-1 => EU_WEST_1
  cluster_type                = "REPLICASET"
  provider_instance_size_name = "M10"
}

resource "mongodbatlas_privatelink_endpoint" "private_endpoint" {
  project_id    = mongodbatlas_project.iot_events.id
  provider_name = "AWS"
  region        = var.region
}

resource "aws_vpc_endpoint" "iot_vpc_endpoint" {
  vpc_id             = module.vpc.vpc_id
  service_name       = mongodbatlas_privatelink_endpoint.private_endpoint.endpoint_service_name
  vpc_endpoint_type  = "Interface"
  subnet_ids         = module.vpc.subnet_ids
  security_group_ids = [module.vpc.security_group_id]
}

# TODO: there isn't a TF resource to create indexes against clusters, so
# we'll need to call the Atlas index HTTP API endpoint here