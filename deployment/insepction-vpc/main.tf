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
}
