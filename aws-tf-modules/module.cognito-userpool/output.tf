output "userpool_id" {
  description = "The id of the user pool"
  value       = var.enabled ? aws_cognito_user_pool.pool[0].id : null
}

output "userpool_arn" {
  description = "The ARN of the user pool"
  value       = var.enabled ? aws_cognito_user_pool.pool[0].arn : null
}

output "userpool_endpoint" {
  description = "The endpoint name of the user pool. Example format: cognito-idp.REGION.amazonaws.com/xxxx_yyyyy"
  value       = var.enabled ? aws_cognito_user_pool.pool[0].endpoint : null
}

output "creation_date" {
  description = "The date the user pool was created"
  value       = var.enabled ? aws_cognito_user_pool.pool[0].creation_date : null
}

output "client_ids" {
  description = "The ids of the user pool clients"
  value       = var.enabled ? aws_cognito_user_pool_client.client.*.id : null
}

output "client_ids_map" {
  description = "The ids map of the user pool clients"
  value       = var.enabled ? { for k, v in aws_cognito_user_pool_client.client : v.name => v.id } : null
}
