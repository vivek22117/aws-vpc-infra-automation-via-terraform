##########################################################
# Terraform configuration for AWS Aurora RDS             #
##########################################################
resource "aws_db_subnet_group" "auth_service_sub_group" {
  count = var.enabled ? 1 : 0

  name        = var.sub_group_name
  description = "Group of DB subnets for Auth-Service"
  subnet_ids  = data.terraform_remote_state.vpc.outputs.db_subnets

  tags = merge(local.common_tags, map("Name", "${var.environment}-auth-serivce"))
}

resource "random_password" "master_password" {
  length  = 16
  special = false
}

resource "aws_rds_cluster" "auth_service_db" {
  count = var.enabled ? 1 : 0

  cluster_identifier = var.cluster_prefix != "" ? format("%s-cluster", var.cluster_prefix) : format("%s-aurora-cluster", var.environment)
  availability_zones = var.azs
  engine             = var.db_engine
  engine_mode        = var.db_engine_mode
  engine_version     = var.db_engine_version

  database_name                = var.database_name
  master_username              = var.username
  master_password              = random_password.master_password.result
  skip_final_snapshot          = var.skip_final_snapshot
  backup_retention_period      = var.backup_retention_period
  preferred_backup_window      = var.preferred_backup_window
  preferred_maintenance_window = var.preferred_maintenance_window
  db_subnet_group_name         = aws_db_subnet_group.auth_service_sub_group[0].name
  vpc_security_group_ids       = [aws_security_group.auth_service_db_sg.id]
  apply_immediately            = var.apply_immediately

  scaling_configuration {
    auto_pause               = var.scaling_auto_pause
    max_capacity             = var.max_capacity
    min_capacity             = var.min_capacity
    seconds_until_auto_pause = var.auto_pause_secs
  }

  tags = merge(local.common_tags, map("Name", "db-${var.cluster_prefix}-${var.environment}"))
}
