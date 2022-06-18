resource "aws_s3_bucket_policy" "allow_access_from_cloudtrail" {
  depends_on = [
    aws_s3_bucket.s3_bucket
  ]

  bucket = aws_s3_bucket.s3_bucket["cloudtrail_monitoring"].id
  policy = data.template_file.s3_policy_template.rendered
}
