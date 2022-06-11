#####===================Global Variables======================#####
variable "environment" {
  type        = string
  description = "Environment to be configured 'dev', 'qa', 'prod'"
}

variable "enabled" {
  type        = bool
  description = "Boolean value to define provision or do-not-provision the resources"
}

variable "default_region" {
  type    = string
  default = "us-east-1"
}

#####=============================Application Variables=================#####
variable "secret_version" {
  type        = string
  description = "New version name for secrets, like v1, v2....., c1, c2.....s1, s2"
}

variable "sub_group_name" {
  type        = string
  description = "Subnet Group name for Aurora DB"
}

variable "cluster_prefix" {
  type        = string
  description = "RDS cluster identifier prefix"
}

variable "azs" {
  type        = list(string)
  description = "A list of AZs for DB cluster storage and instance"
}

variable "db_engine" {
  type        = string
  description = "The name of the Database engine to be used, valid values: aurora, aurora-mysql, aurora-postgresql"
}

variable "db_engine_mode" {
  type        = string
  description = "The database engine mode, valid values: global, multimaster, parallelquery, provisioned(DEFAULT), serverless"
}

variable "db_engine_version" {
  type        = string
  description = "The database engine version"
}

variable "database_name" {
  type        = string
  description = "Auth-service database name"
}

variable "username" {
  type        = string
  description = "Database user name"
}

variable "password" {
  type        = string
  description = "Database password"
}

variable "skip_final_snapshot" {
  type        = bool
  description = "Should a final snapshot be created on cluster destroy"
}

variable "backup_retention_period" {
  type        = string
  description = "How long to keep backups for (in days)"
}

variable "preferred_backup_window" {
  type        = string
  description = "When to perform DB backups"
}

variable "preferred_maintenance_window" {
  type        = string
  description = "When to perform DB maintenance"
}

variable "apply_immediately" {
  type        = string
  default     = "false"
  description = "Determines whether or not any DB modifications are applied immediately"
}

variable "sg_name" {
  type        = string
  description = "Database security group name"
}

variable "scaling_auto_pause" {
  type        = bool
  description = "Pause the scaled instance when idle"
}

variable "max_capacity" {
  type        = number
  description = "Maximum number of db-instance at any given time"
}

variable "min_capacity" {
  type        = number
  description = "Minimum number of db-instance at any given time"
}


variable "auto_pause_secs" {
  type        = number
  description = "Number of seconds before an Aurora DB cluster in serverless mode is paused"
}

variable "sns_email_list" {
  type        = list(string)
  description = "The email list of subscribers to the SNS Topic."
}


#####===============Local variables==================#####
locals {
  common_tags = {
    owner       = "Vivek"
    team        = "DD-Team"
    environment = var.environment
    Project     = "DD-Auth-Service"
  }
}
