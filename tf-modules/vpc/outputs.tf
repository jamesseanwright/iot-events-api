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

output "security_group_id" {
  value = aws_security_group.security_group.id
  description = "The ID of our IoT events default security group"
}
