output "ecs-cluster-log-group" {
  value       = aws_cloudwatch_log_group.test_ecs_cluster_log_group.name
  description = "AWS cloud-watch log group name"
}

output "ecs-clustser-name" {
  value       = aws_ecs_cluster.test_ecs_cluster.name
  description = "AWS Test ECS cluster name"
}

output "ecs-cluster-lb-arn" {
  value       = aws_alb.ecs_cluster_alb.arn
  description = "ECS cluster load balancer ARN!"
}

output "ecs-cluster-lb-domain" {
  value       = aws_alb.ecs_cluster_alb.dns_name
  description = "ECS cluster load balancer DNS name!"
}

output "ecs-cluster-lb-zoneId" {
  value       = aws_alb.ecs_cluster_alb.zone_id
  description = "ECS cluster load balancer Zone Id!"
}


output "ecs-cluster-id" {
  value       = aws_ecs_cluster.test_ecs_cluster.id
  description = "AWS TEST ECS Cluster id!"
}

output "alb-target-group-arn" {
  value = aws_lb_target_group.ecs_alb_default_target_group.arn
}

output "alb-listner-arn" {
  value = aws_lb_listener.ecs_alb_listener.arn
}

output "ecs_optimized_ami" {
  value = data.aws_ssm_parameter.ecs_ami.value
}

output "config_server_fqdn" {
  value = aws_route53_record.ecs_cluster_record[0].fqdn
}
