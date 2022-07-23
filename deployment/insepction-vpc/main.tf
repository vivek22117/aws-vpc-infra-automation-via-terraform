###############################################################
#           Inspection VPC module deployment                  #
###############################################################
module "inspection_vpc" {
  source = "../../aws-tf-modules/module.aws-inspection-vpc"

  default_region = var.default_region
  environment    = var.environment
  isMonitoring   = var.isMonitoring
  owner          = var.owner
  project        = var.project
  team           = var.team


  cidr_block                        = var.cidr_block
  create_network_firewall           = var.create_network_firewall
  delete_protection                 = var.delete_protection
  enable_dns                        = var.enable_dns
  enable_nat_gateway                = var.enable_nat_gateway
  firewall_policy_change_protection = var.firewall_policy_change_protection
  instance_tenancy                  = var.instance_tenancy
  subnet_change_protection          = var.subnet_change_protection
  support_dns                       = var.support_dns
}
