resource "tls_private_key" "ca" {
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "ca_cert" {
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
