resource "aws_ses_domain_identity" "ses-domain" {
  domain = "cloud-interview.in"
}


resource "aws_ses_domain_dkim" "ses-domain-dkim" {
  domain = aws_ses_domain_identity.ses-domain.domain
}

resource "aws_s3_bucket" "emails_bucket" {
  bucket = "blog-api-ses-integration"
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
            "Resource": "arn:aws:s3:::gabriel.araujo-emails/*"
        }
    ]
}
POLICY
  depends_on = [
    null_resource.delay
  ]
}

resource "aws_ses_receipt_rule" "store" {
  name          = "store"
  rule_set_name = "default-rule-set"
  enabled       = true
  scan_enabled  = true

  add_header_action {
    header_name  = "Custom-Header"
    header_value = "Added by SES"
    position     = 1
  }

  s3_action {
    bucket_name       = aws_s3_bucket.emails_bucket.id
    object_key_prefix = "incoming"
    position          = 2
  }

  depends_on = [
    aws_s3_bucket_policy.bucket_policy,
    aws_ses_receipt_rule.store
  ]
}
