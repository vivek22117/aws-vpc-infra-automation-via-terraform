#################################################
#           Database Security Group             #
#################################################
resource "aws_security_group" "auth_service_db_sg" {
  name = var.sg_name

  description = "Allow traffic for auth-service security group"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
    "0.0.0.0/0"]
  }

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    cidr_blocks = [
    data.terraform_remote_state.vpc.outputs.vpc_cidr]
  }

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    security_groups = [
    data.terraform_remote_state.vpc.outputs.bastion_sg]
  }

  tags = local.common_tags
}


resource "aws_secretsmanager_secret" "auth_service_secrets" {
  depends_on = [
    aws_rds_cluster.auth_service_db,
    random_password.master_password
  ]

  name        = "auth-service/client/db-credentials"
  description = "Auth-Service DB credentials"

  tags = merge(local.common_tags, map("Name", "${var.environment}-auth-serivce"))
}

resource "aws_secretsmanager_secret_version" "auth_service_cred" {
  depends_on = [
    aws_rds_cluster.auth_service_db,
    random_password.master_password
  ]

  secret_id = aws_secretsmanager_secret.auth_service_secrets.id

  secret_string = jsonencode(
    {
      "username" : aws_rds_cluster.auth_service_db[0].master_username,
      "password" : random_password.master_password.result,
      "engine" : "postgresql",
      "host" : aws_rds_cluster.auth_service_db[0].endpoint,
      "port" : aws_rds_cluster.auth_service_db[0].port,
      "dbClusterIdentifier" : aws_rds_cluster.auth_service_db[0].cluster_identifier
    }
  )
}
