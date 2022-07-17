######################################################################
# Global variables for VPC, Subnet, Routes and Bastion Host          #
######################################################################
variable "default_region" {
  type        = string
  description = "AWS region to deploy resources"
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

#######===========================VPN Client Variables=============================#######
variable "client_cidr_block" {
  description = "AWS VPN client cidr block"
  type        = string
}
variable "split_tunnel" {
  description = "Split tunnel traffic"
  type        = bool
}
variable "vpn_inactive_period" {
  description = "VPN inactive period in seconds"
  type        = number
}
variable "session_timeout_hours" {
  description = "Session timeout hours"
  type        = number
}
variable "logs_retention_in_days" {
  description = "VPN client list!?"
  type        = number
}

variable "aws-vpn-client-list" {
  description = "VPN client list of users ?"
  type        = list(string)
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
