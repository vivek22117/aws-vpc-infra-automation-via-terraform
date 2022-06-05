data "aws_route53_zone" "cloud_interview" {
  name = "cloud-interview.in"
}

resource "aws_route53_record" "ecs_cluster_record" {
  count = var.enabled != "" ? 1 : 0

  zone_id = data.aws_route53_zone.cloud_interview.zone_id
  name    = aws_cognito_user_pool_domain.user_pool_domain.domain
  type    = "A"

  alias {
    name                   = aws_cognito_user_pool_domain.user_pool_domain.cloudfront_distribution_arn
    zone_id                = "Z2FDTNDATAQYW2"
    evaluate_target_health = false
  }
}
