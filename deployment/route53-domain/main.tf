########################################################
#           Route53 module deployment                  #
########################################################
module "route53_config" {
  source = "../../aws-tf-modules/module.aws-route53"

  default_region = var.default_region
  environment    = var.environment
  route53_domain = var.route53_domain
  cognito_domain = var.cognito_domain
}
