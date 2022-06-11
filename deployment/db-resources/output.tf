output "db_cluster_arn" {
  value = module.auth_api_db_impl.db_cluster_arn
}

output "db_secret_arn" {
  value = module.auth_api_db_impl.db_secret_arn
}

output "db_endpoint" {
  value = module.auth_api_db_impl.db_endpoint
}

output "db_reader_endpoint" {
  value = module.auth_api_db_impl.db_reader_endpoint
}

output "sns_topic_arn" {
  value = module.auth_api_db_impl.sns_topic_arn
}
