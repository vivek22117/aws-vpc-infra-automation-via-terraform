locals {
  password_policy_is_null = {
    minimum_length                   = var.password_policy_minimum_length
    require_lowercase                = var.password_policy_require_lowercase
    require_numbers                  = var.password_policy_require_numbers
    require_symbols                  = var.password_policy_require_symbols
    require_uppercase                = var.password_policy_require_uppercase
    temporary_password_validity_days = var.password_policy_temporary_password_validity_days
  }

  password_policy_not_null = var.password_policy == null ? local.password_policy_is_null : {
    minimum_length                   = lookup(var.password_policy, "minimum_length", null) == null ? var.password_policy_minimum_length : lookup(var.password_policy, "minimum_length")
    require_lowercase                = lookup(var.password_policy, "require_lowercase", null) == null ? var.password_policy_require_lowercase : lookup(var.password_policy, "require_lowercase")
    require_numbers                  = lookup(var.password_policy, "require_numbers", null) == null ? var.password_policy_require_numbers : lookup(var.password_policy, "require_numbers")
    require_symbols                  = lookup(var.password_policy, "require_symbols", null) == null ? var.password_policy_require_symbols : lookup(var.password_policy, "require_symbols")
    require_uppercase                = lookup(var.password_policy, "require_uppercase", null) == null ? var.password_policy_require_uppercase : lookup(var.password_policy, "require_uppercase")
    temporary_password_validity_days = lookup(var.password_policy, "temporary_password_validity_days", null) == null ? var.password_policy_temporary_password_validity_days : lookup(var.password_policy, "temporary_password_validity_days")

  }

  # Return the default values
  password_policy = var.password_policy == null ? [local.password_policy_is_null] : [local.password_policy_not_null]
}

resource "aws_cognito_user_pool" "pool" {

  name                     = var.user_pool_name
  alias_attributes         = var.alias_attributes
  auto_verified_attributes = var.auto_verified_attributes

  username_configuration {
    case_sensitive = var.is_username_case_sensitive
  }


  /** Required Standard Attributes*/
  schema {
    attribute_data_type = "String"
    mutable             = true
    name                = "email"
    required            = true
    string_attribute_constraints {
      min_length = 1
      max_length = 2048
    }
  }

  schema {
    attribute_data_type = "String"
    mutable             = true
    name                = "given_name"
    required            = true
    string_attribute_constraints {
      min_length = 1
      max_length = 2048
    }
  }

  schema {
    attribute_data_type = "String"
    mutable             = true
    name                = "family_name"
    required            = true
    string_attribute_constraints {
      min_length = 1
      max_length = 2048
    }
  }

  /** Custom Attributes */
  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "PersonalInfo"
    required                 = false
    string_attribute_constraints {
      min_length = 1
      max_length = 2048
    }
  }

  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "Role"
    required                 = false
    string_attribute_constraints {
      min_length = 1
      max_length = 2048
    }
  }

  dynamic "password_policy" {
    for_each = local.password_policy
    content {
      minimum_length                   = lookup(password_policy.value, "minimum_length")
      require_lowercase                = lookup(password_policy.value, "require_lowercase")
      require_numbers                  = lookup(password_policy.value, "require_numbers")
      require_symbols                  = lookup(password_policy.value, "require_symbols")
      require_uppercase                = lookup(password_policy.value, "require_uppercase")
      temporary_password_validity_days = lookup(password_policy.value, "temporary_password_validity_days")
    }
  }


}

output "user_pool_id" {
  value = aws_cognito_user_pool.pool.id
}
