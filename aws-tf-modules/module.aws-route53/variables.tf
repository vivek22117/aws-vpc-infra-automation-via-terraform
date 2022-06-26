###############################
#    Global variables         #
###############################
variable "default_region" {
  type        = string
  description = "AWS region to deploy our resources"
}

variable "environment" {
  type        = string
  description = "Environment to be configured 'dev', 'qa', 'prod'"
}

variable "enabled" {
  description = "Change to false to avoid deploying any resources"
  type        = bool
  default     = true
}

#####===================================Route53 Configuration===================================#####
variable "route53_domain" {
  type        = string
  description = "Domain name registered with AWS Route 53"
}

variable "cognito_domain" {
  description = "Cognito User Pool domain"
  type        = string
}
