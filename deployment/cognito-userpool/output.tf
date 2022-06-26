output "userpool_id" {
  description = "The id of the user pool"
  value       = module.cognito_userpool.user_pool_id
}

output "userpool_arn" {
  description = "The ARN of the user pool"
  value       = module.cognito_userpool.userpool_arn
}

output "userpool_endpoint" {
  description = "The endpoint name of the user pool. Example format: cognito-idp.REGION.amazonaws.com/xxxx_yyyyy"
  value       = module.cognito_userpool.userpool_endpoint
}

output "creation_date" {
  description = "The date the user pool was created"
  value       = module.cognito_userpool.creation_date
}

output "client_ids" {
  description = "The ids of the user pool clients"
  value       = module.cognito_userpool.client_ids
}

output "client_ids_map" {
  description = "The ids map of the user pool clients"
  value       = module.cognito_userpool.client_ids_map
}
