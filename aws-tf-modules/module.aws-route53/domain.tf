resource "aws_cognito_user_pool_domain" "user_pool_domain" {
  count = !var.enabled || var.cognito_domain == null || var.cognito_domain == "" ? 0 : 1

  domain          = var.cognito_domain
  certificate_arn = aws_acm_certificate.cognito_auth_acm.arn
  user_pool_id    = data.terraform_remote_state.cognito_userpool.outputs.userpool_id

  depends_on = [
    aws_route53_record.cognito_web_1,
    aws_route53_record.cognito_web_2
  ]
}
