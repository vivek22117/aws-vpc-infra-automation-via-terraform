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
}

variable "instance_tenancy" {
  type        = string
  description = "Type of instance tenancy required default/dedicated"
}

variable "enable_dns" {
  type        = string
  description = "To use private DNS within the VPC"
}

variable "support_dns" {
  type        = string
  description = "To use private DNS support within the VPC"
}
