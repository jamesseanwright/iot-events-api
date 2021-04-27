resource "aws_vpc" "iot_events" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "iot-events"
  }
}

resource "aws_subnet" "subnet_a" {
  vpc_id = aws_vpc.iot_events.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "eu-west-1a"

  tags = {
    Name = "iot-events-subnet-a"
  }
}

resource "aws_subnet" "subnet_b" {
  vpc_id = aws_vpc.iot_events.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-west-1b"

  tags = {
    Name = "iot-events-subnet-b"
  }
}

resource "aws_subnet" "subnet_c" {
  vpc_id = aws_vpc.iot_events.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "eu-west-1c"

  tags = {
    Name = "iot-events-subnet-c"
  }
}
