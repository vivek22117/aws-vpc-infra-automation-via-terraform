######################################################################
# Global variables for CloudTrail Configuration                      #
######################################################################
variable "profile" {
  type        = string
  description = "AWS Profile name for credentials"
}

variable "enable_log_file_validation" {
  type        = bool
  description = "Specifies whether log file integrity validation is enabled"
}

variable "is_multi_region_trail" {
  type        = bool
  description = "Specifies whether the trail is created in the current region or in all regions"
}

variable "include_global_service_events" {
  type        = bool
  description = "Specifies whether the trail is publishing events from global services such as IAM to the log files"
}

variable "enable_trail_logging" {
  type        = bool
  description = "Enable logging for the trail"
}

variable "log_retention" {
  type        = number
  description = "Number of days to keep logs"
}

variable "s3_key_prefix" {
  type        = string
  description = "S3 bucket prefix for aws cloud trail"
}

variable "event_selector" {
  type = list(object({
    include_management_events = bool
    read_write_type           = string

    data_resource = list(object({
      type   = string
      values = list(string)
    }))
  }))

  description = "Specifies an event selector for enabling data event logging"
}

variable "is_organization_trail" {
  type        = bool
  description = "The trail is an AWS Organizations trail"
}

######################################################
# Variables for S3 Configuration                     #
######################################################
variable "default_region" {
  type        = string
  description = "Name of the region where the Trail bucket should be created."
}

variable "metric_name_space" {
  type        = string
  description = "Name to the cloudwatch metric space"
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

#####=============Local variables===============#####
locals {
  common_tags = {
    owner       = var.owner
    team        = var.team
    environment = var.environment
  }
}
