resource "aws_vpc" "guardian_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true

  tags = {
    Name = "guardian_vpc"
  }
}


resource "aws_subnet" "public_subnet_1" {
  availability_zone = "us-east-1a"
  vpc_id            = aws_vpc.guardian_vpc.id
  cidr_block        = var.public_subnet_cidr_1

  tags = {
    Name = "public_subnet_1"
  }
}


resource "aws_subnet" "public_subnet_2" {
  availability_zone = "us-east-1b"
  vpc_id            = aws_vpc.guardian_vpc.id
  cidr_block        = var.public_subnet_cidr_2

  tags = {
    Name = "public_subnet_2"
  }
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.guardian_vpc.id

  tags = {
    Name = "igw"
  }
}


resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.guardian_vpc.id

  tags = {
    Name = "public_route_table"
  }
}


resource "aws_route" "route" {
  destination_cidr_block = var.internet_cidr
  route_table_id         = aws_route_table.route_table.id
  gateway_id             = aws_internet_gateway.igw.id
}


resource "aws_route_table_association" "public_subnet_1_route_table" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.route_table.id
}


resource "aws_route_table_association" "public_subnet_2_route_table" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_db_subnet_group" "new_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
}

resource "aws_security_group" "production_SG" {
  name        = "allow_traffic"
  description = "Allow inbound traffic and outbound"
  vpc_id      = aws_vpc.guardian_vpc.id

  tags = {
    Name = "production_SG"
  }
}


resource "aws_vpc_security_group_ingress_rule" "ingress_rule" {
  security_group_id = aws_security_group.production_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 5432
  ip_protocol       = "TCP"
  to_port           = 5432
}

resource "aws_vpc_security_group_egress_rule" "egress_rule" {
  security_group_id = aws_security_group.production_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
