default_region = "us-east-1"
enabled        = true

component_name = "blog-api-userpool"

user_pool_name             = "blog-api-userpool"
is_username_case_sensitive = true

alias_attributes = [
  "email"
]
auto_verified_attributes = [
  "email"
]

mfa_configuration = "OPTIONAL"
software_token_mfa_configuration = {
  enabled = true
}

admin_create_user_config = {
  allow_admin_create_user_only = false
  email_message                = "Dear {username}, your verification code is {####}."
  email_subject                = "Here, your verification code baby"
  sms_message                  = "Your username is {username} and temporary password is {####}."
}

email_configuration = {
  email_sending_account  = "DEVELOPER"
  reply_to_email_address = "admin@doubledigit-solutions.in"
}

schemas = [
  {
    attribute_data_type      = "Boolean"
    developer_only_attribute = false
    mutable                  = true
    name                     = "approved"
    required                 = false
  },
  {
    attribute_data_type      = "DateTime"
    developer_only_attribute = false
    mutable                  = false
    name                     = "created"
    required                 = false
  }
]

string_schemas = [
  {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "email"
    required                 = true

    string_attribute_constraints = {
      min_length = 7
      max_length = 256
    }
  },
  {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "address"
    required                 = false

    string_attribute_constraints = {
      min_length = 7
      max_length = 2048
    }
  },
  {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "phone_number"
    required                 = false

    string_attribute_constraints = {
      min_length = 7
      max_length = 2048
    }
  },
  {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "name"
    required                 = false

    string_attribute_constraints = {
      min_length = 7
      max_length = 2048
    }
  },
  {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = false
    name                     = "role"
    required                 = false

    string_attribute_constraints = {
      min_length = 7
      max_length = 25
    }
  }
]


recovery_mechanisms = [
  {
    name     = "verified_email"
    priority = 1
  },
  {
    name     = "verified_phone_number"
    priority = 2
  }
]

password_policy = {
  minimum_length                   = 10
  require_lowercase                = false
  require_numbers                  = true
  require_symbols                  = true
  require_uppercase                = true
  temporary_password_validity_days = 120
}

verification_message_template = {
  default_email_option = "CONFIRM_WITH_CODE"
}

user_pool_add_ons = {
  advanced_security_mode = "ENFORCED"
}

clients = [
  {
    name                                 = "blog-app-client"
    allowed_oauth_flows                  = ["code"]
    allowed_oauth_flows_user_pool_client = true
    allowed_oauth_scopes                 = ["email", "openid"]
    callback_urls                        = ["https://cloud-interview.in"]
    default_redirect_uri                 = "https://cloud-interview.in"
    generate_secret                      = false
    prevent_user_existence_errors        = "ENABLED"
    read_attributes                      = ["email", "email_verified", "phone_number"]
    explicit_auth_flows = [
      "ALLOW_REFRESH_TOKEN_AUTH",
      "ALLOW_USER_PASSWORD_AUTH",
      "ALLOW_ADMIN_USER_PASSWORD_AUTH"
    ]
    access_token_validity  = 3600
    id_token_validity      = 60
    refresh_token_validity = 10
    token_validity_units = {
      access_token  = "seconds"
      id_token      = "minutes"
      refresh_token = "days"
    }
    supported_identity_providers = ["COGNITO"]
  }
]


