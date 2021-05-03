output "id" {
  value = aws_vpc.iot_events.id
  description = "The ID of our IoT events VPC"
}

output "subnet_ids" {
  value = [
    aws_subnet.subnet_a.id,
    aws_subnet.subnet_b.id,
    aws_subnet.subnet_c.id
  ]
  description = "The IDs of our IoT events subnets"
}

output "atlas_resource_security_group_id" {
  value = aws_security_group.atlas_resource.id
  description = "The ID of the security group for resources that need to communicate with the Atlas private endpoint"
}

output "atlas_endpoint_security_group_id" {
  value = aws_security_group.atlas_endpoint.id
  description = "The ID of the security group for the Atlas private endpoint, allowing it to communicate with VPC resources"
}
