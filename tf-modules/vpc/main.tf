resource "aws_vpc" "iot_events" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "iot-events"
  }
}

resource "aws_subnet" "subnet_a" {
  vpc_id = aws_vpc.iot_events.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "${var.region}a"

  tags = {
    Name = "iot-events-subnet-a"
  }
}

resource "aws_subnet" "subnet_b" {
  vpc_id = aws_vpc.iot_events.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "${var.region}b"

  tags = {
    Name = "iot-events-subnet-b"
  }
}

resource "aws_subnet" "subnet_c" {
  vpc_id = aws_vpc.iot_events.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "${var.region}c"

  tags = {
    Name = "iot-events-subnet-c"
  }
}

resource "aws_security_group" "atlas_resource" {
  vpc_id = aws_vpc.iot_events.id
  name = "iot-events-atlas-resource-security-group"
  description = "The security group for resources that need to communicate with the Atlas private endpoint"

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [aws_vpc.iot_events.cidr_block]
  }
}

resource "aws_security_group" "atlas_endpoint" {
  vpc_id = aws_vpc.iot_events.id
  name = "iot-events-atlas-endpoint-security-group"
  description = "The security group for the Atlas private endpoint, allowing it to communicate with VPC resources"

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [aws_vpc.iot_events.cidr_block]
  }
}
