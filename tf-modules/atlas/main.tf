terraform {
  required_providers {
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "0.9.1"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }
  }
}

locals {
  database_username = "events-user"
}

# The public and private keys are configured via the
# MONGODB_ATLAS_PUBLIC_KEY and MONGODB_ATLAS_PRIVATE_KEY
# environment variables respectively
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

resource "random_password" "events_user_password" {
  length = 16
}

resource "mongodbatlas_database_user" "user" {
  username           = local.database_username
  password           = random_password.events_user_password.result
  project_id         = mongodbatlas_project.iot_events.id
  auth_database_name = "admin"

  roles {
    role_name     = "readWrite"
    database_name = "events"
  }

  roles {
    role_name     = "readAnyDatabase"
    database_name = "admin"
  }

  scopes {
    name = "events"
    type = "CLUSTER"
  }
}

resource "mongodbatlas_privatelink_endpoint" "private_endpoint" {
  project_id    = mongodbatlas_project.iot_events.id
  provider_name = "AWS"
  region        = var.region
}

resource "aws_vpc_endpoint" "iot_vpc_endpoint" {
  vpc_id             = var.vpc_id
  service_name       = mongodbatlas_privatelink_endpoint.private_endpoint.endpoint_service_name
  vpc_endpoint_type  = "Interface"
  subnet_ids         = var.subnet_ids
  security_group_ids = [var.security_group_id]
}

resource "mongodbatlas_privatelink_endpoint_service" "iot_vpc_endpoint_svc" {
  provider_name       = "AWS"
  project_id          = mongodbatlas_project.iot_events.id
  private_link_id     = mongodbatlas_privatelink_endpoint.private_endpoint.private_link_id
  endpoint_service_id = aws_vpc_endpoint.iot_vpc_endpoint.id
}

# TODO: add unique index against device ID, date, and event type fields.
# Sadly, there's no Terraform resource for creating indexes against Atlas
# clusters, so we'd have to do this by calling the API directly.
