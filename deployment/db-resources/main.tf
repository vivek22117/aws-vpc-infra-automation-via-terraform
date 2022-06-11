####################################################
#        Auth API Module DB Implementation         #
####################################################
module "auth_api_db_impl" {
  source = "../../aws-tf-modules/module.database-infra"

  default_region = var.default_region
  environment    = var.environment

  enabled = var.enabled

  sg_name        = var.sg_name
  secret_version = var.secret_version

  cluster_prefix    = var.cluster_prefix
  db_engine         = var.db_engine
  db_engine_mode    = var.db_engine_mode
  db_engine_version = var.db_engine_version

  username      = var.username
  password      = var.password
  database_name = var.database_name

  azs                          = var.azs
  auto_pause_secs              = var.auto_pause_secs
  backup_retention_period      = var.backup_retention_period
  max_capacity                 = var.max_capacity
  min_capacity                 = var.min_capacity
  preferred_backup_window      = var.preferred_backup_window
  preferred_maintenance_window = var.preferred_maintenance_window
  scaling_auto_pause           = var.scaling_auto_pause
  skip_final_snapshot          = var.skip_final_snapshot
  sub_group_name               = var.sub_group_name
  sns_email_list               = var.sns_email_list
}
