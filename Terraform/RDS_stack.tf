# Create a VPC 
resource "aws_vpc" "rds_vpc" {
  cidr_block           = var.rds_vpc_cidr_block
  enable_dns_hostnames = true

  tags = {
    Name = "rds_vpc"
  }
}

# Create public_subnet_1
resource "aws_subnet" "rds_public_subnet_1" {
  availability_zone = "us-east-1a"
  vpc_id            = aws_vpc.rds_vpc.id
  cidr_block        = var.rds_public_subnet_cidr_1

  tags = {
    Name = "rds_public_subnet_1"
  }
}

# Create public_subnet_2 
resource "aws_subnet" "rds_public_subnet_2" {
  availability_zone = "us-east-1b"
  vpc_id            = aws_vpc.rds_vpc.id
  cidr_block        = var.rds_public_subnet_cidr_2

  tags = {
    Name = "rds_public_subnet_2"
  }
}

# Create aws_internet_gateway
resource "aws_internet_gateway" "rds_igw" {
  vpc_id = aws_vpc.rds_vpc.id

  tags = {
    Name = "rds_igw"
  }
}

# Create route_table
resource "aws_route_table" "rds_route_table" {
  vpc_id = aws_vpc.rds_vpc.id

  tags = {
    Name = "rds_public_route_table"
  }
}

# Create aws_route
resource "aws_route" "rds_route" {
  destination_cidr_block = var.rds_internet_cidr
  route_table_id         = aws_route_table.rds_route_table.id
  gateway_id             = aws_internet_gateway.rds_igw.id
}

# Create an association public_subnet_1
resource "aws_route_table_association" "public_subnet_1_route_table" {
  subnet_id      = aws_subnet.rds_public_subnet_1.id
  route_table_id = aws_route_table.rds_route_table.id
}

# Create an association public_subnet_2
resource "aws_route_table_association" "public_subnet_2_route_table" {
  subnet_id      = aws_subnet.rds_public_subnet_2.id
  route_table_id = aws_route_table.rds_route_table.id
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = [aws_subnet.rds_public_subnet_1.id, aws_subnet.rds_public_subnet_2.id]
}

resource "aws_ssm_parameter" "rds_db_username" {
  name  = "rds_db_username"
  type  = "String"
  value = "victor"
}

resource "random_password" "password" {
  length  = 8
  special = false
}

resource "aws_ssm_parameter" "rds_db_password" {
  name  = "rds_db_password"
  type  = "String"
  value = random_password.password.result
}

resource "aws_db_instance" "rds_project_db" {
  allocated_storage      = 10
  db_name                = "rds_project"
  engine                 = "postgres"
  engine_version         = "16.6"
  instance_class         = "db.r5.large"
  username               = aws_ssm_parameter.rds_db_username.value
  password               = aws_ssm_parameter.rds_db_password.value
  parameter_group_name   = "default.postgres16"
  skip_final_snapshot    = true
  publicly_accessible    = true
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_SG.id]
}

resource "aws_security_group" "rds_SG" {
  name        = "allow_traffic"
  description = "Allow inbound traffic and outbound"
  vpc_id      = aws_vpc.rds_vpc.id

  tags = {
    Name = "rds-SG"
  }
}


resource "aws_vpc_security_group_ingress_rule" "rds_ingress_rule" {
  security_group_id = aws_security_group.rds_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 5432
  ip_protocol       = "TCP"
  to_port           = 5432
}

resource "aws_vpc_security_group_egress_rule" "rds_egress_rule" {
  security_group_id = aws_security_group.rds_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" 
}








