data "aws_route53_zone" "cloud_interview" {
  name         = var.route53_domain
  private_zone = false
}

# This creates an SSL certificate
resource "aws_acm_certificate" "cognito_auth_acm" {

  domain_name               = var.cognito_domain
  subject_alternative_names = ["www.auth.cloud-interview.in"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# This is a DNS record for the ACM certificate validation to prove we own the domain
resource "aws_route53_record" "cert_validation" {
  depends_on = [aws_acm_certificate.cognito_auth_acm]

  for_each = {
    for dvo in aws_acm_certificate.cognito_auth_acm.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  type            = each.value.type
  zone_id         = data.aws_route53_zone.cloud_interview.id
  ttl             = 300
}

# This tells terraform to cause the route53 validation to happen
resource "aws_acm_certificate_validation" "cert" {
  depends_on = [aws_route53_record.cert_validation, aws_acm_certificate.cognito_auth_acm]

  timeouts {
    create = "20m"
  }

  certificate_arn         = aws_acm_certificate.cognito_auth_acm.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

resource "aws_route53_record" "cognito_web_1" {
  depends_on = [aws_cognito_user_pool.pool]

  zone_id = data.aws_route53_zone.cloud_interview.zone_id
  name    = "auth.cloud-interview.in"
  type    = "A"

  alias {
    name = aws_cognito_user_pool_domain.user_pool_domain[0].cloudfront_distribution_arn
    # This zone_id is fixed
    zone_id                = "Z2FDTNDATAQYW2"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cognito_web_2" {
  depends_on = [aws_cognito_user_pool.pool]

  zone_id = data.aws_route53_zone.cloud_interview.zone_id
  name    = "www.auth.cloud-interview.in.in"
  type    = "A"

  alias {
    name = aws_cognito_user_pool_domain.user_pool_domain[0].cloudfront_distribution_arn
    # This zone_id is fixed
    zone_id                = "Z2FDTNDATAQYW2"
    evaluate_target_health = false
  }
}

