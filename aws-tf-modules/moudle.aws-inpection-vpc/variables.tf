######################################################################
# Global variables for VPC, Subnet, Routes and Bastion Host          #
######################################################################
variable "default_region" {
  type        = string
  description = "AWS region to deploy resources"
}

variable "cidr_block" {
  type        = string
  description = "CIDR range for vpc"
  default     = "10.0.0.0/16"
}

variable "instance_tenancy" {
  type        = string
  description = "Type of instance tenancy required default/dedicated"
  default     = "default"
}

variable "enable_dns" {
  type        = string
  description = "To use private DNS within the VPC"
  default     = true
}

variable "support_dns" {
  type        = string
  description = "To use private DNS support within the VPC"
  default     = true
}

variable "enable_nat_gateway" {
  type        = string
  description = "want to create nat-gateway or not"
  default     = true
}

######################################################
# Local variables defined                            #
######################################################
variable "team" {
  type        = string
  description = "Owner team for this application infrastructure"
}

variable "owner" {
  type        = string
  description = "Owner of the product"
}

variable "environment" {
  type        = string
  description = "Environment to be used"
}

variable "isMonitoring" {
  type        = bool
  description = "Monitoring is enabled or disabled for the resources creating"
}

variable "project" {
  type        = string
  description = "Monitoring is enabled or disabled for the resources creating"
}

#####============================Firewall variables==============================#####
variable "delete_protection" {
  type        = bool
  description = "A boolean flag indicating whether it is possible to delete the firewall."
  default     = false
}

variable "firewall_policy_change_protection" {
  type        = bool
  description = "A boolean flag indicating whether it is possible to change the associated firewall policy."
  default     = false
}

variable "subnet_change_protection" {
  type        = bool
  description = "A boolean flag indicating whether it is possible to change the associated subnet(s)."
  default     = false
}

variable "create_network_firewall" {
  type        = bool
  description = "Set to false if you just want to create the security policy, stateless and stateful rules"
  default     = true
}

#####=============Local variables===============#####
locals {
  common_tags = {
    owner       = var.owner
    team        = var.team
    environment = var.environment
    monitoring  = var.isMonitoring
    Project     = var.project
  }
}
