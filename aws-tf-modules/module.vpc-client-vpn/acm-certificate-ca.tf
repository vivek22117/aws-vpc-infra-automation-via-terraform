####################################################
#           AWS ACM Certificate for CA             #
####################################################
resource "tls_private_key" "ca" {
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "ca" {
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.ca.private_key_pem

  subject {
    common_name  = "${var.project}.${var.environment}.vpn.ca"
    organization = var.project
  }
  validity_period_hours = 87600
  is_ca_certificate     = true
  allowed_uses = [
    "cert_signing",
    "crl_signing",
  ]
}

resource "aws_acm_certificate" "ca_cert" {
  private_key      = tls_private_key.ca.private_key_pem
  certificate_body = tls_self_signed_cert.ca.cert_pem

  tags = merge(local.common_tags, tomap({ "Name" = "vpn-ca-cert" }))

}


############################################################
#           Add private Key and CA cert in SSM             #
############################################################
resource "aws_ssm_parameter" "vpn_ca_key" {
  name        = "/${var.project}/${var.environment}/acm/vpn/ca_key"
  description = "VPN CA key"
  type        = "SecureString"
  value       = tls_private_key.ca.private_key_pem

  tags = merge(local.common_tags, tomap({ "Name" = "ca-key" }))
}
resource "aws_ssm_parameter" "vpn_ca_cert" {
  name        = "/${var.project}/${var.environment}/acm/vpn/ca_cert"
  description = "VPN CA cert"
  type        = "SecureString"
  value       = tls_self_signed_cert.ca.cert_pem

  tags = merge(local.common_tags, tomap({ "Name" = "ca-cert" }))

}
