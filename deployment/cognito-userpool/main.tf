#################################################################
#           Cognito userpool module deployment                  #
#################################################################
module "cognito_userpool" {
  source = "../../aws-tf-modules/module.cognito-userpool"

  default_region = var.default_region
  environment    = var.environment
  component_name = var.component_name

  user_pool_name             = var.user_pool_name
  is_username_case_sensitive = var.is_username_case_sensitive
  alias_attributes           = var.alias_attributes
  auto_verified_attributes   = var.auto_verified_attributes

  mfa_configuration                = var.mfa_configuration
  software_token_mfa_configuration = var.software_token_mfa_configuration
  admin_create_user_config         = var.admin_create_user_config
  email_configuration              = var.email_configuration
  verification_message_template    = var.verification_message_template

  schemas             = var.schemas
  string_schemas      = var.string_schemas
  recovery_mechanisms = var.recovery_mechanisms

  password_policy   = var.password_policy
  user_pool_add_ons = var.user_pool_add_ons


  clients = var.clients
}
