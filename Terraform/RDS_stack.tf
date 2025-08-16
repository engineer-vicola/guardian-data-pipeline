resource "aws_ssm_parameter" "new_rds_db_username" {
  name  = "rds_db_username"
  type  = "String"
  value = "victor"
}

resource "random_password" "password" {
  length  = 12
  special = false
}

resource "aws_ssm_parameter" "new_rds_db_password" {
  name  = "/production/new_rds_db_password/"
  type  = "String"
  value = random_password.password.result
}

resource "aws_db_instance" "new_rds_project_db" {
  allocated_storage      = 10
  db_name                = "rds_project"
  engine                 = "postgres"
  engine_version         = "16.6"
  instance_class         = "db.r5.large"
  username               = aws_ssm_parameter.new_rds_db_username.value
  password               = aws_ssm_parameter.new_rds_db_password.value
  parameter_group_name   = "default.postgres16"
  skip_final_snapshot    = true
  publicly_accessible    = true
  db_subnet_group_name   = aws_db_subnet_group.new_subnet_group.name
  vpc_security_group_ids = [aws_security_group.production_SG.id]
  maintenance_window     = "sun:02:00-03:00"

}

