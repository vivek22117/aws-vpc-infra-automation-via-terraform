###########################################################
#           VPN Client module deployment                  #
###########################################################
module "vpc" {
  source = "../../aws-tf-modules/module.vpc-client-vpn"

  default_region = var.default_region
  environment    = var.environment
  isMonitoring   = var.isMonitoring
  owner          = var.owner
  project        = var.project
  team           = var.team

  aws-vpn-client-list    = []
  client_cidr_block      = ""
  logs_retention_in_days = 0
  session_timeout_hours  = 0
  split_tunnel           = false
  vpn_inactive_period    = 0
}
