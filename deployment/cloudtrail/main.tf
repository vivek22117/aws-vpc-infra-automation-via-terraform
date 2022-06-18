####################################################
#        Dev VPC module configuration              #
####################################################
module "vpc-cloudtrail" {
  source = "../../aws-tf-modules/module.cloudTrail"

  team         = var.team
  owner        = var.owner
  environment  = var.environment
  isMonitoring = var.isMonitoring
  component    = var.component
  project      = var.project

  default_region = var.default_region

  enable_log_file_validation    = var.enable_log_file_validation
  is_multi_region_trail         = var.is_multi_region_trail
  include_global_service_events = var.include_global_service_events
  enable_trail_logging          = var.enable_trail_logging
  log_retention                 = var.log_retention
  is_organization_trail         = var.is_organization_trail

  s3_key_prefix = var.s3_key_prefix

  metric_name_space = var.metric_name_space

  event_selector = var.event_selector
}
