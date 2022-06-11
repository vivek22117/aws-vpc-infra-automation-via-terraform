output "db_cluster_arn" {
  value = aws_rds_cluster.auth_service_db[*].arn
}

output "db_secret_arn" {
  value = aws_secretsmanager_secret.auth_service_secrets.arn
}

output "db_endpoint" {
  value = aws_rds_cluster.auth_service_db[*].endpoint
}

output "db_reader_endpoint" {
  value = aws_rds_cluster.auth_service_db[*].port
}

output "sns_topic_arn" {
  value = aws_sns_topic.user_registration_topic.arn
}
