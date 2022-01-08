resource "aws_route53_record" "ecs_cluster_record" {
  count = var.ecs_dns_name != "" ? 1 : 0

  zone_id = "Z029807318ZYBD0ARNFLS"
  name    = var.ecs_dns_name
  type    = "A"

  alias {
    name                   = aws_alb.ecs_cluster_alb.dns_name
    zone_id                = aws_alb.ecs_cluster_alb.zone_id
    evaluate_target_health = false
  }
}