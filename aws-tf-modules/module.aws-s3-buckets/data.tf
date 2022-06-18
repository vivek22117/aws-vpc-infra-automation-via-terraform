data "template_file" "s3_policy_template" {
  template = file("${path.module}/policy-doc/cloudtrail-bucket-policy.json")

  vars = {
    s3_arn = aws_s3_bucket.s3_bucket["cloudtrail_monitoring"].arn
  }
}
