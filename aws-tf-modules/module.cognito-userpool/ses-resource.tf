//resource "aws_ses_domain_identity" "ses-domain" {
//  domain = "cloud-interview.in"
//}
//
//resource "aws_route53_record" "ses_verif" {
//  zone_id = aws_route53_zone.zone.zone_id
//  name    = "_amazonses.${aws_ses_domain_identity.primary.id}"
//  type    = "TXT"
//  ttl     = "600"
//  records = [aws_ses_domain_identity.primary.verification_token]
//}
//
//resource "aws_ses_domain_identity_verification" "ses_verif" {
//  domain = aws_ses_domain_identity.primary.id
//
//  depends_on = [aws_route53_record.ses_verif]
//}

#In order for emails to work with our domain, we need an MX record that tells other mail servers where to send their @ourdomain emails.
//resource "aws_route53_record" "email" {
//  zone_id = aws_route53_zone.zone.zone_id
//  name    = aws_route53_zone.zone.name
//  type    = "MX"
//  ttl     = "600"
//  records = ["10 inbound-smtp.${data.aws_region.current.name}.amazonaws.com"]
//}

//# Example Route53 MX record
//resource "aws_route53_record" "example_ses_domain_mail_from_mx" {
//  zone_id = aws_route53_zone.example.id
//  name    = aws_ses_domain_mail_from.example.mail_from_domain
//  type    = "MX"
//  ttl     = "600"
//  records = ["10 feedback-smtp.us-east-1.amazonses.com"] # Change to the region in which `aws_ses_domain_identity.example` is created
//}
//
//# Example Route53 TXT record for SPF
//resource "aws_route53_record" "example_ses_domain_mail_from_txt" {
//  zone_id = aws_route53_zone.example.id
//  name    = aws_ses_domain_mail_from.example.mail_from_domain
//  type    = "TXT"
//  ttl     = "600"
//  records = ["v=spf1 include:amazonses.com -all"]
//}

//resource "aws_ses_domain_dkim" "ses-domain-dkim" {
//  domain = aws_ses_domain_identity.ses-domain.domain
//}

resource "aws_ses_email_identity" "ses-domain" {
  email = "admin@doubledigit-solutions.com"
}

resource "aws_s3_bucket" "emails_bucket" {
  bucket = "blog-api-ses-integration"

  force_destroy = true

  lifecycle {
    prevent_destroy = false
  }
}

resource "null_resource" "delay" {
  provisioner "local-exec" {
    command = "sleep 10"
  }
  triggers = {
    "after" = aws_s3_bucket.emails_bucket.id
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.emails_bucket.id

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowSESPuts",
            "Effect": "Allow",
            "Principal": {
                "Service": "ses.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "${aws_s3_bucket.emails_bucket.arn}/incoming/*"
        }
    ]
}
POLICY
  depends_on = [
    null_resource.delay
  ]
}

resource "aws_ses_receipt_rule_set" "main" {
  rule_set_name = "report-email-rules"
}

resource "aws_ses_active_receipt_rule_set" "main" {
  rule_set_name = "report-email-rules"
  depends_on    = [aws_ses_receipt_rule_set.main]
}


resource "aws_ses_receipt_rule" "store" {
  name          = "store"
  rule_set_name = aws_ses_receipt_rule_set.main.rule_set_name
  enabled       = true
  scan_enabled  = false

  add_header_action {
    header_name  = "Custom-Header"
    header_value = "Added by SES"
    position     = 1
  }

  s3_action {
    bucket_name       = aws_s3_bucket.emails_bucket.id
    object_key_prefix = "incoming/"
    position          = 2
  }

  depends_on = [
    aws_s3_bucket_policy.bucket_policy,
    aws_ses_receipt_rule.store
  ]
}
